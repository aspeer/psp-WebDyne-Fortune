use WebDyne::Constant;
$_={
    'WebDyne::Constant' => {
        WEBDYNE_ERROR_SHOW          => 1,
        WEBDYNE_ERROR_SHOW_EXTENDED => 1,
        WEBDYNE_HTML_PARAM          => {
            %{ $WebDyne::Constant::WEBDYNE_HTML_PARAM },
            style => 'https://cdn.jsdelivr.net/npm/water.css@2/out/water.css'
        }
    }
}

