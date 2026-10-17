import from game.api { new_case, question, hint, accuse, get_notebook }
import from game.walkers { new_case, question, hint, accuse }
import from .client.app { ClientApp }
import ".styles.global.css";

def:pub app() -> JsxElement {
    return <ClientApp />;
}
