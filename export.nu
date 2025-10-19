def "main dist" [] {
    main manual

    let version = open typst.toml | get package.version
    let dist = $'./dist/($version)'
    let gallery = $dist | path join gallery
    let docs = $dist | path join docs

    mkdir $dist
    mkdir $gallery
    mkdir $docs

    cp typst.toml $dist
    cp LICENSE $dist
    cp README.md $dist
    cp -r src $dist
    cp ./gallery/*.png $gallery
    cp ./docs/manual.pdf $docs
}

def "main manual" [] {
    let result = do -i { ^typst compile --root . ./docs/manual.typ } | complete
    if $result.exit_code != 0 {
        print $result.stderr
        exit $result.exit_code
    }
}

def "main gallery" [] {
    ls gallery/*.typ
    | get name
    | each { |it| ^typst compile --root . --format png $it }
    | ignore
}

def main [] {}
