#!/usr/bin/env bash
# usage: ./endpoints.sh https://example.com/page
set -u
url=$1
base=$(grep -oE '^https?://[^/]+' <<<"$url")
[[ $url =~ ^https?://[^/]+/?$ ]] && dir=$base || dir=${url%/*}
q="\"'\`"
re="[$q](/[^$q[:space:]<>]+|https?://[^$q[:space:]<>]+|\.\.?/[^$q[:space:]<>]+)[$q]"

html=$(curl -sL "$url")
{
  echo "$html"
  grep -oE "<script[^>]+src=[\"'][^\"']+" <<<"$html" | sed -E "s/.*src=[\"']//" | while read -r s; do
    case $s in
      //*) s="https:$s" ;;
      /*) s="$base$s" ;;
      http*) ;;
      *) s="$dir/$s" ;;
    esac
    curl -sL "$s"
  done
} | grep -oE "$re" | sed -E 's/^.(.*).$/\1/' | sort -u
