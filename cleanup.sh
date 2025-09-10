#!/usr/bin/env bash
set -euo pipefail

confirm() {
  read -r -p "Proceed? [y/N] " ans
  [[ "${ans:-N}" =~ ^[Yy]$ ]]
}

echo "== Disk usage before =="
df -h /

echo "== Docker =="
docker system df || true
echo "Prune Docker builders & caches (keeps running containers)."
if confirm; then
  docker builder prune -af || true
  docker system prune -af || true
  docker volume prune -f || true
fi

echo "== Xcode =="
echo "Delete DerivedData, Archives, old DeviceSupport?"
if confirm; then
  killall Xcode Simulator 2>/dev/null || true
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
  rm -rf ~/Library/Developer/Xcode/Archives/*

  # --- Interactive iOS DeviceSupport cleanup (macOS/Bash 3.2 compatible) ---
  echo "List of installed iOS DeviceSupport folders:"
  devs=()
  while IFS= read -r -d '' d; do devs+=("$d"); done < <(find ~/Library/Developer/Xcode/iOS\ DeviceSupport -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

  if ((${#devs[@]} == 0)); then
    echo "(none found)"
  else
    for i in "${!devs[@]}"; do
      base="$(basename "${devs[$i]}")"
      printf "[%d] %s\n" "$i" "$base"
    done

    echo
    echo "Choose DeviceSupport cleanup mode:"
    echo "  (K) Keep specific indices (delete all others)"
    echo "  (D) Delete specific indices (keep all others)"
    read -r -p "Mode [K/D] (default K): " mode
    mode=${mode:-K}

    # Indexed array to mark selections (works in Bash 3.2)
    pick=()
    parse_indices() {
      local raw="$1"; raw="${raw//,/ }"
      for idx in $raw; do
        if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 0 && idx < ${#devs[@]} )); then
          pick[$idx]=1
        else
          echo "Skipping invalid index: $idx"
        fi
      done
    }

    if [[ "$mode" =~ ^[Kk]$ ]]; then
      echo
      echo "Enter indices to KEEP (comma-separated). Leave blank to keep the 2 most recently modified."
      read -r -p "Keep indices: " keep_input
      if [[ -z "$keep_input" ]]; then
        # Find the two newest by mtime (portable with BSD tools)
        pairs=()
        for i in "${!devs[@]}"; do
          m=$(stat -f %m "${devs[$i]}") || m=0
          pairs+=("$m:$i")
        done
        IFS=$'\n' sorted=( $(printf '%s\n' "${pairs[@]}" | sort -rn) ); unset IFS
        last_idx="${sorted[0]#*:}"
        prev_idx="${sorted[1]#*:}"
        [[ -n "$last_idx" ]] && pick[$last_idx]=1
        [[ -n "$prev_idx" ]] && pick[$prev_idx]=1
        echo "Keeping indices: ${prev_idx:-} ${last_idx:-} (newest two), deleting the rest."
      else
        parse_indices "$keep_input"
        echo "Keeping indices: ${!pick[*]}"
      fi

      # Delete any DeviceSupport not in the keep set
      for i in "${!devs[@]}"; do
        if [[ -z "${pick[$i]:-}" ]]; then
          echo "Deleting: [${i}] $(basename "${devs[$i]}")"
          rm -rf "${devs[$i]}"
        fi
      done

    else
      echo
      echo "Enter indices to DELETE (comma-separated). Leave blank to skip DeviceSupport deletion."
      read -r -p "Delete indices: " del_input
      if [[ -n "$del_input" ]]; then
        parse_indices "$del_input"
        for i in "${!pick[@]}"; do
          echo "Deleting: [${i}] $(basename "${devs[$i]}")"
          rm -rf "${devs[$i]}"
        done
      else
        echo "No DeviceSupport deletion requested."
      fi
    fi
  fi

  # Simulator caches (safe to purge)
  rm -rf ~/Library/Developer/CoreSimulator/Caches/*
fi

echo "== Package managers =="
echo "npm / yarn / pnpm caches?"
if confirm; then
  npm cache clean --force || true
  yarn cache clean || true
  pnpm store prune || true
fi

echo "== Flutter / Gradle caches =="
if confirm; then
  rm -rf ~/.pub-cache/* || true
  rm -rf ~/.gradle/caches/* ~/.gradle/daemon/* || true
fi

echo "== VS Code caches =="
if confirm; then
  rm -rf ~/Library/Application\ Support/Code/Cache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/CachedData/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/Code\ Cache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/GPUCache/* 2>/dev/null || true
  rm -rf ~/Library/Application\ Support/Code/Service\ Worker/CacheStorage/* || true
  rm -rf ~/Library/Application\ Support/Code/User/workspaceStorage/* || true
fi

echo "== Multipass =="
multipass list --disk || true
echo "Run 'multipass purge' to free deleted instances."
read -r -p "Run purge now? [y/N] " mp
[[ "${mp:-N}" =~ ^[Yy]$ ]] && multipass purge || true

echo "== Homebrew =="
if confirm; then
  brew cleanup -s || true
  rm -rf ~/Library/Caches/Homebrew/* || true
fi

echo "== General macOS caches & logs (Requires Sudo) =="
if confirm; then
  rm -rf ~/Library/Caches/* || true
  qlmanage -r cache || true
  rm -rf ~/Library/Logs/* || true
fi

echo "== Git aggressive GC in current repo? (runs in ./) =="
if confirm; then
  git gc --prune=now --aggressive || true
fi

echo "== Disk usage after =="
df -h /
echo "Done."