import from game.api { new_case, question, hint, accuse, get_notebook }

cl {
    import ".styles/global.css";
    import from .client.app { ClientApp }

    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
