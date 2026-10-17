# Whodunit

Question suspects, examine clues, and solve a Sri Lankan mystery. Built in **Jac** for AI Hackathon 2026 (Jaseci Labs, University of Moratuwa).

## How to play

1. Click **New Case**. The AI writes a new mystery: a crime, four suspects, hidden clues and one culprit.
2. Read the **case file**, then click a suspect and **question them** in the chat. Each suspect answers in character, and some of them lie.
3. When a suspect lets something important slip, a **clue** lands in your **notebook**.
4. Pick a clue and press **Show clue** to the right suspect. If it breaks their lie, they **crack** (+150).
5. Stuck? **Hint** gives one nudge (−100) and never names the culprit.
6. **Accuse** a suspect with a one-line reason. A wrong guess costs 300 and you get one more chance.
7. The **result screen** tells the true story and gives your score and rank: Rookie, Inspector or Master Detective.

Scoring: start at 1000 · question −50 · hint −100 · wrong accusation −300 · crack a suspect +150.

## How it works

**AI proposes. Walkers + graph decide.** The model only talks and suggests. Jac code checks every rule against the graph, and the browser never receives secrets.

| Layer | Where | What it does |
|---|---|---|
| UI | `client/` (`cl` Jac code, compiled to React) | Start screen, case file, suspects, chat, notebook, accuse dialog, result screen |
| API | `game/api.jac` (`def:pub` functions) | `new_case`, `question` (also used to show a clue), `hint`, `accuse`, `get_notebook` |
| Rules | `game/rules.jac` (plain Jac, no AI) | Case validation, scoring, cracks, safe public view |
| Data | `game/graph.jac` (nodes and edges on `root`) | `Case`, `Suspect`, `Clue`, `ChatLine` · `Knows`, `Breaks`, `Said` |
| AI | `game/agents.jac` (`by llm()` functions) | Game Master, Suspect, Hint, Reveal |
| Safety net | `game/fallback.jac` | A hand-written case, used only if generation fails |

## Run it locally

```bash
jac install
jac start main.jac
```

Then open http://localhost:8000.

The model is set in `jac.toml` under `[byllm.model]`. Put the matching provider key in an **environment variable** (a local `.env` file, which is git-ignored, or a Jac Hammer project variable). **Never commit a key.**

## Team

- **Sithil**: frontend, deploy, README
- **Nithika**: AI agents, demo video
- **Yohan**: backend graph, rules, fallback case
