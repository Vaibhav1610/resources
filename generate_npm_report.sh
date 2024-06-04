#!/bin/bash

output_file="npm_report.md"

echo "# NPM Report" > "$output_file"
echo "Generated on $(date)" >> "$output_file"
echo -e "\n## Outdated Dependencies\n" >> "$output_file"

#--no-color to avoid formatting issue
echo '```' >> "$output_file"
npm outdated --no-color >>$output_file 2>&1
echo '```' >> "$output_file"

echo -e "\n\n## Vulnerable Dependencies\n" >> "$output_file"


audit_output=$(npm audit --json)


echo -e "\n### Vulnerabilities\n" >> "$output_file"


jq -r '.advisories | to_entries[] | "- **Severity**: **\(.value.severity | ascii_upcase)**\n- **Title**: \(.value.title)\n- **Package**: \(.value.module_name)\n- **Patched in**: \(.value.patched_versions)\n- **Dependency of**: \(.value.findings[0].paths[0])\n- **Path**: \(.value.findings[0].paths[0])\n\(.value.cwe | if . != null then "- **CWE**: \(.)" else empty end)\n\(.value.cves | if . != null then "- **CVEs**: \(.)" else empty end)\n- **More info**: [\(.value.url)](\(.value.url))\n\n---\n"' <<< "$audit_output" >> "$output_file"


echo -e "\n\n## Deprecated Packages\n" >> "$output_file"

jq -r '.packages | to_entries[] | select(.value.deprecated != null) | "- **Package**: \(.key)\n- **Deprecated**: \(.value.deprecated)\n\n---\n"' package-lock.json >> "$output_file"

  
echo "Report has been generated and saved to $output_file"
