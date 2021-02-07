#!/usr/bin/fish

set TECHS_FILE /tmp/techs.txt

echo -n > $TECHS_FILE

for line in (cat Dockerfile | grep "RUN build_")
    set VERSION (echo $line | cut -d " " -f 3)
    set TECH_SCRIPT (echo $line | cut -d " " -f 2)

    switch $TECH_SCRIPT
    case "build_php.sh"
        set TECH php
        set TECH_VERBOSE PHP
    case "build_python.sh"
        set TECH python
        set TECH_VERBOSE Python
    case "build_node.sh"
        set TECH node
        set TECH_VERBOSE Node
    case "build_ruby.sh"
        set TECH ruby
        set TECH_VERBOSE Ruby
    case "build_deno.sh"
        set TECH deno
        set TECH_VERBOSE Deno
    case '*'
        set TECH unknown
    end

    echo "                        \"$TECH-$VERSION\" \"  $TECH_VERBOSE $VERSION\" \\" >> $TECHS_FILE
end

cat rosti.sh.tmp | while read -l line
    if [ "$line" = "{{TECHS}}" ]
        cat $TECHS_FILE
    else
        echo $line
    end
    
end
