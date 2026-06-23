#!/bin/bash
# pre-push hook — blocks pushes containing credential patterns
# Install: cp scripts/pre-push-cred-check.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push
# Emergency bypass: git push --no-verify

FOUND=0

# Patterns (ERE syntax) — each matches something that looks like a real credential
PATTERNS=(
    '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY'   # private keys
    'AKIA[0-9A-Z]{16}'                                   # AWS access key ID
    'ASIA[0-9A-Z]{16}'                                   # AWS temporary key
    'ghp_[A-Za-z0-9_]{36,}'                             # GitHub classic PAT
    'github_pat_[A-Za-z0-9_]+'                          # GitHub fine-grained PAT
    'ghs_[A-Za-z0-9]{36,}'                              # GitHub Actions token
    'sk-[a-zA-Z0-9]{40,}'                               # OpenAI / generic sk- key
    '(databaseSecret|firebaseSecret|FB_SECRET|FIREBASE_SECRET)[[:space:]]*[:=][[:space:]]*[^[:space:]]{12,}'
    '(password|passwd|secret|api[_-]?key|access[_-]?token|auth[_-]?token)[[:space:]]*[:=][[:space:]]*['\''"][^'\''"]{8,}['\''"]'
)

while IFS=' ' read -r local_ref local_sha remote_ref remote_sha; do
    # Deleting a branch — nothing to scan
    [ "$local_sha" = "0000000000000000000000000000000000000000" ] && continue

    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch — scan commits not yet on any remote
        diff=$(git log -p "$local_sha" --not --remotes 2>/dev/null)
    else
        diff=$(git log -p "${remote_sha}..${local_sha}" 2>/dev/null)
    fi

    [ -z "$diff" ] && continue

    for pattern in "${PATTERNS[@]}"; do
        matches=$(printf '%s' "$diff" | grep -E '^\+' | grep -E "$pattern" || true)
        if [ -n "$matches" ]; then
            if [ $FOUND -eq 0 ]; then
                echo ""
                echo "PUSH BLOCKED: possible credentials in outgoing commits"
                echo ""
            fi
            echo "  Pattern: $pattern"
            echo "$matches" | head -3 | sed 's/^/  /'
            echo ""
            FOUND=1
        fi
    done
done

if [ $FOUND -ne 0 ]; then
    echo "Review the matches above before pushing."
    echo "If this is a false positive: git push --no-verify"
    echo ""
    exit 1
fi

exit 0
