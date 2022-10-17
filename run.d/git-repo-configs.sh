#!/bin/bash

script () {
  cat > "$1"
  chmod 0755 "$1"
}

for i in ~/src/github.com/Shopify/*/.git; do
  (
    export GIT_DIR=$i
    git config remote.origin.skipFetchAll true
    script $i/hooks/pre-commit <<EOF
#!/bin/bash -e
$HOME/bin/pre-commit ${i%.git}
EOF
  )
done