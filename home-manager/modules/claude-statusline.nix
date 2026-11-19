# claude-statusline.nix — statusline do Claude Code via home-manager.
#
# Uso: importe no seu home.nix
#   imports = [ ./claude-statusline.nix ];
#
# O script vai para o /nix/store já apontando para o node e o git do Nix,
# e a chave "statusLine" é mesclada no ~/.claude/settings.json a cada switch
# (o resto do arquivo é preservado, e o Claude Code continua podendo gravá-lo).
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.claude-statusline;

  script = pkgs.writeText "claude-statusline.js" ''
    #!/usr/bin/env node
    // Statusline do Claude Code — lê o JSON da sessão via stdin e imprime 3 linhas.
    'use strict';

    const { execFileSync } = require('node:child_process');
    const os = require('node:os');

    // ── helpers ────────────────────────────────────────────────────────────────
    const ESC = '\x1b[';
    const RESET = `''${ESC}0m`;
    const paint = (style, text) => (style ? `''${ESC}''${style}m''${text}''${RESET}` : String(text));
    const SEP = ' · ';

    const get = (obj, path) =>
      path.split('.').reduce((o, k) => (o != null && typeof o === 'object' ? o[k] : undefined), obj);

    const num = (v, def = 0) => {
      const n = Number(v);
      return Number.isFinite(n) ? n : def;
    };

    function tildify(p) {
      if (!p) return ''';
      const home = os.homedir().replace(/\/$/, ''');
      if (home && p.startsWith(home)) return '~' + p.slice(home.length);
      const m = p.match(/^\/(?:Users|home)\/[^/]+(.*)$/);
      return m ? '~' + m[1] : p;
    }

    function bar(pct, width = 10, filled = '▰', empty = '▱') {
      const p = Math.min(100, Math.max(0, Math.trunc(num(pct))));
      const n = Math.floor((p * width + 50) / 100);
      return filled.repeat(n) + empty.repeat(width - n);
    }

    function fmtTokens(v) {
      const n = Math.max(0, Math.trunc(num(v)));
      if (n < 1e3) return String(n);
      const [div, unit] = n < 1e6 ? [1e3, 'k'] : [1e6, 'M'];
      const whole = Math.floor(n / div);
      const dec = Math.floor((n % div) / (div / 10));
      return dec ? `''${whole}.''${dec}''${unit}` : `''${whole}''${unit}`;
    }

    function durHuman(ms) {
      const total = Math.floor(num(ms) / 1000);
      if (total < 60) return `''${total}s`;
      const m = Math.floor(total / 60), s = total % 60;
      if (m < 60) return s ? `''${m}m ''${s}s` : `''${m}m`;
      const h = Math.floor(m / 60), mm = m % 60;
      return mm ? `''${h}h ''${mm}m` : `''${h}h`;
    }

    // resets_at: aceita epoch (s ou ms) ou string ISO.
    function relTime(target) {
      if (target == null || target === ''') return ''';
      let t = typeof target === 'number' || /^\d+(\.\d+)?$/.test(target) ? num(target) : Date.parse(target) / 1000;
      if (!Number.isFinite(t)) return ''';
      if (t > 1e12) t /= 1000; // veio em ms
      const now = process.env.STATUSLINE_CLOCK_OVERRIDE ? num(process.env.STATUSLINE_CLOCK_OVERRIDE) : Date.now() / 1000;
      const diff = Math.floor(t - now);
      if (diff <= 0) return ''';
      const pad = (x) => String(x).padStart(2, '0');
      if (diff < 60) return `T-''${diff}s`;
      if (diff < 3600) return `T-''${Math.floor(diff / 60)}m''${pad(diff % 60)}s`;
      return `T-''${Math.floor(diff / 3600)}h''${pad(Math.floor((diff % 3600) / 60))}m`;
    }

    // Cache do git: o statusline roda a cada mensagem, e em repo grande o
    // `git status` pode levar centenas de ms. Guarda o resultado por GIT_TTL_MS
    // num arquivo fixo por diretório (não usar PID: cada execução é um processo novo).
    const GIT_TTL_MS = num(process.env.STATUSLINE_GIT_TTL_MS, 5000);

    function gitInfo(cwd) {
      if (!cwd) return null;
      const fs = require('node:fs');
      const path = require('node:path');
      const crypto = require('node:crypto');
      const key = crypto.createHash('sha1').update(cwd).digest('hex').slice(0, 12);
      const cacheFile = path.join(os.tmpdir(), `claude-statusline-git-''${key}.json`);
      try {
        if (Date.now() - fs.statSync(cacheFile).mtimeMs < GIT_TTL_MS) {
          return JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
        }
      } catch {} // sem cache ou cache corrompido → consulta o git
      const info = gitInfoUncached(cwd);
      try {
        fs.writeFileSync(cacheFile, JSON.stringify(info));
      } catch {}
      return info;
    }

    // Uma única chamada ao git devolve branch + dirty.
    function gitInfoUncached(cwd) {
      try {
        const out = execFileSync('${pkgs.git}/bin/git', ['-C', cwd, '--no-optional-locks', 'status', '--porcelain=v2', '--branch'], {
          encoding: 'utf8',
          stdio: ['ignore', 'pipe', 'ignore'],
          timeout: 1000,
        });
        let branch = ''';
        let dirty = false;
        for (const line of out.split('\n')) {
          if (line.startsWith('# branch.head ')) branch = line.slice(14);
          else if (line.startsWith('# branch.oid ') && !branch) branch = line.slice(13, 20);
          else if (line && !line.startsWith('#')) dirty = true;
        }
        if (branch === '(detached)') {
          const oid = out.match(/^# branch\.oid (\w{7})/m);
          branch = oid ? `@''${oid[1]}` : 'detached';
        }
        return { branch, dirty };
      } catch {
        return null; // não é repo, git ausente ou timeout
      }
    }

    // Cor do contexto. Os limiares originais eram em tokens absolutos
    // (50k/80k/150k); aqui usa-se % para funcionar igual em janelas de 200k e 1M.
    function ctxColor(pct) {
      if (pct > 75) return '38;5;167'; // vermelho
      if (pct > 40) return '38;5;214'; // laranja
      if (pct > 25) return '38;5;226'; // amarelo
      return '38;5;114'; // verde
    }

    // ── main ───────────────────────────────────────────────────────────────────
    function render(d) {
      const lines = [];

      // Linha 1: diretório · git · linhas alteradas
      {
        const cwd = get(d, 'workspace.current_dir') || d.cwd || ''';
        const parts = [paint('38;2;101;169;255', `📂 ''${tildify(cwd)}`)];
        const git = gitInfo(cwd);
        if (git) {
          parts.push(
            paint('3;38;2;166;227;161', `🌿 git:''${git.branch} `) +
              (git.dirty ? paint('1;38;2;190;0;0', '❌') : paint('38;2;79;136;0', '✅')),
          );
        }
        const added = num(get(d, 'cost.total_lines_added'));
        const removed = num(get(d, 'cost.total_lines_removed'));
        parts.push(paint('1;38;2;83;180;58', `↑''${added}++`) + ' ' + paint('1;38;2;255;79;79', `↓''${removed}--`));
        lines.push(parts.join(SEP));
      }

      // Linha 2: modelo · thinking · fast · contexto · output style
      {
        const parts = [paint('1;38;2;166;97;251', `🤖 ''${get(d, 'model.display_name') || '?'}`)];

        const effort = get(d, 'effort.level');
        if (get(d, 'thinking.enabled') === true && effort) parts.push(`🧠 ''${effort}`);
        if (get(d, 'fast_mode') === true) parts.push(paint('3', '⚡fast'));

        const cw = d.context_window || {};
        if (cw.context_window_size) {
          const used = num(cw.total_input_tokens);
          const total = num(cw.context_window_size);
          const pct = cw.used_percentage != null ? num(cw.used_percentage) : (used / total) * 100;
          const color = ctxColor(pct);
          parts.push(
            paint('1;38;2;255;166;0', 'CTX ') +
              paint(`1;''${color}`, bar(pct)) +
              ' ' +
              paint(color, `''${fmtTokens(used)}/''${fmtTokens(total)} (''${Math.trunc(pct)}%)`),
          );
        }

        const style = get(d, 'output_style.name');
        if (style && style !== 'default') parts.push(`🎭 ''${style}`);
        lines.push(parts.join(SEP));
      }

      // Linha 3: rate limits · custo · duração
      {
        const parts = [];
        for (const [key, label] of [['five_hour', '5h'], ['seven_day', '7d']]) {
          const rl = get(d, `rate_limits.''${key}`);
          if (!rl || rl.used_percentage == null) continue; // ex.: uso via API key
          const pct = num(rl.used_percentage);
          const reset = relTime(rl.resets_at);
          parts.push(
            paint('38;2;52;226;226', `''${label} ''${bar(pct)} ~ `) +
              paint('1', `''${Math.round(pct)}%''${reset ? ' ' + reset : '''}`),
          );
        }
        parts.push(`💵 $''${num(get(d, 'cost.total_cost_usd')).toFixed(2)}`);
        parts.push(paint('38;2;220;91;91', `⌛ ''${durHuman(get(d, 'cost.total_duration_ms'))}`));
        lines.push(parts.join(SEP));
      }

      return lines.join('\n') + '\n';
    }

    let raw = ''';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (c) => (raw += c));
    process.stdin.on('end', () => {
      let data = {};
      try {
        data = JSON.parse(raw || '{}');
      } catch {}
      try {
        process.stdout.write(render(data));
      } catch (e) {
        process.stdout.write(`statusline error: ''${e.message}\n`);
      }
    });
  '';

  command = "${cfg.nodePackage}/bin/node ${script}";
in
{
  options.programs.claude-statusline = {
    enable = lib.mkEnableOption "statusline personalizado do Claude Code";

    nodePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs;
      defaultText = lib.literalExpression "pkgs.nodejs";
      description = "Node usado para rodar o statusline.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.claude";
      description = "Pasta de configuração do Claude Code (CLAUDE_CONFIG_DIR).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.claudeStatusline = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      f=${lib.escapeShellArg cfg.configDir}/settings.json
      mkdir -p "$(dirname "$f")"
      [ -s "$f" ] || echo '{}' > "$f"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --arg cmd ${lib.escapeShellArg command} \
          '.statusLine = {type: "command", command: $cmd}' "$f" > "$tmp"; then
        mv "$tmp" "$f"
      else
        rm -f "$tmp"
        echo "claude-statusline: não consegui ler $f (JSON inválido?), nada foi alterado" >&2
      fi
    '';
  };
}
