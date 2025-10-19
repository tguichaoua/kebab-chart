def "main dist" [] {
    let version = open typst.toml | get package.version
    let dist = $'./dist/($version)'
    let gallery = $dist | path join gallery

    mkdir $dist
    mkdir $gallery

    cp typst.toml $dist
    cp LICENSE $dist
    cp README.md $dist
    cp -r src $dist
    cp gallery/*.png $gallery
}

def "main manual" [] {
    ^typst compile --root . ./docs/manual.typ
}

def "main gallery" [] {
    ls gallery/*.typ
    | get name
    | each { |it| ^typst compile --root . --format png $it }
    | ignore
}

def main [] {}
