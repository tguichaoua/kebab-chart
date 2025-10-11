def "main dist" [] {
    let version = open typst.toml | get package.version
    let dist = $'./dist/($version)'
    mkdir $dist

    cp typst.toml $dist
    cp LICENSE $dist
    cp README.md $dist
    cp -r src $dist
    cp -r gallery $dist
}

def "main examples" [] {
    ls -s examples 
    | get name 
    | each { 
        |it| ^typst compile --root . --format png ./examples/($it) ./gallery/($it | path parse | upsert extension png | path join)
    } 
    | ignore
}

def main [] {}
