# Safety-net case, used only when AI generation fails twice. Same shape as the Game Master output.
import from agents { CaseSpec, SuspectSpec, ClueSpec }

def load_fallback_case(count: int) -> CaseSpec {
    kamal = SuspectSpec(
        id="s1", name="Kamal", role="driver", style="nervous",
        public_alibi="At the garage all evening.",
        secret="Left the garage at 8:30 and borrowed the bridal room key to look at the necklace. Did NOT steal it.",
        lie="Says he was at the garage all evening.", knows=[]
    );
    nimali = SuspectSpec(
        id="s2", name="Nimali", role="cousin", style="calm",
        public_alibi="In the hall with the family.",
        secret="Phoned the garage at 8:45 and the mechanic said Kamal had already left. Also saw Ruwan near the bridal room at 9.",
        lie=None, knows=["k1", "k3"]
    );
    ruwan = SuspectSpec(
        id="s3", name="Ruwan", role="caterer", style="rude",
        public_alibi="Plating dinner all evening.",
        secret="Slipped into the bridal room through the window and took the necklace.",
        lie="Says he never left the kitchen.", knows=[]
    );
    dilani = SuspectSpec(
        id="s4", name="Dilani", role="photographer", style="chatty",
        public_alibi="Shooting the hall.",
        secret="Photographed muddy footprints under the bridal room window and Sunil smoking behind the hall at 8:55.",
        lie=None, knows=["k2"]
    );
    sunil = SuspectSpec(
        id="s5", name="Sunil", role="usher", style="calm",
        public_alibi="Stood at the main door all night.",
        secret="Slipped out to smoke behind the hall around 8:55. Did NOT steal anything.",
        lie="Says he never left the main door.", knows=[]
    );
    k1 = ClueSpec(id="k1", title="Garage log", text="Kamal left the garage at 8:30pm", breaks="s1");
    k2 = ClueSpec(id="k2", title="Muddy footprints", text="Muddy footprints near the bridal room window", breaks=None);
    k3 = ClueSpec(id="k3", title="Nimali's sighting", text="Nimali saw Ruwan near the bridal room at 9", breaks="s3");
    k4 = ClueSpec(id="k4", title="Smoking photo", text="A photo shows Sunil smoking behind the hall at 8:55", breaks="s5");
    suspects = [kamal, nimali, ruwan, dilani];
    clues = [k1, k2, k3];
    if count == 3 {
        nimali.knows = ["k1", "k3", "k2"];
        suspects = [kamal, nimali, ruwan];
    } elif count == 5 {
        dilani.knows = ["k2", "k4"];
        suspects = [kamal, nimali, ruwan, dilani, sunil];
        clues = [k1, k2, k3, k4];
    }
    return CaseSpec(
        title="The Stolen Necklace",
        where="A wedding hall in Kandy",
        what="At 9pm the bride's gold necklace vanished from the bridal room. The door was locked from the inside.",
        culprit_id="s3",
        true_story="Ruwan slipped into the bridal room through the window while the guests were at dinner and took the necklace. Nimali saw him near the room at 9, and muddy footprints under the window match the kitchen yard. Kamal lied only because he had secretly borrowed the key to look at the necklace.",
        suspects=suspects, clues=clues
    );
}
