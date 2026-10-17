"""Stock suspect photos, picked from the suspect's role.

Photos are free-licence images from Unsplash (unsplash.com/license), loaded by URL.
To swap a photo, replace its id in a list below (the part after "photo-" in an
images.unsplash.com link). To add a role, add a keyword list in `photo_for`.
If a photo fails to load, the polaroid falls back to the suspect's initial.
"""

glob BASE: str = "https://images.unsplash.com/photo-";
glob SIZE: str = "?w=480&h=480&fit=crop&crop=faces&auto=format&q=70";

glob OFFICER: list[str] = ["1529478490015-00f1a2f8f5cd", "1771340590599-fefa36e184b3", "1771340589678-cb6c920e1b5c"];
glob GUARD: list[str] = ["1485230405346-71acb9518d9c", "1773580995586-b0195c43386c", "1618371690240-e0d46eead4b8"];
glob CHEF: list[str] = ["1583394293214-28ded15ee548", "1689588532679-4bb5fdd8f6d5", "1701878198293-d1f3641efdb3"];
glob BUSINESS: list[str] = ["1560250097-0b93528c311a", "1648474484044-bb82df2f5a1f", "1758518727984-17b37f2f0562"];
glob DOCTOR: list[str] = ["1622253692010-333f2da6031d", "1758691463582-11aea602cd4a", "1594824476967-48c8b964273f"];
glob PHOTOGRAPHER: list[str] = ["1603574670812-d24560880210", "1549981832-2ba2ee913334"];
glob DRIVER: list[str] = ["1746676388300-0b83f9627f62", "1777637802987-fb30ac38e58a"];
glob MEN: list[str] = [
    "1670110531916-41045e83cb0a", "1596604820148-da737958af16", "1712425718137-491250cfde88",
    "1667382136327-5f78dc5cf835", "1653055645127-54ec96add7b5", "1762709412743-3395ed866302",
    "1697517529954-b6845f3245a0"
];
glob WOMEN: list[str] = [
    "1628477116196-48afe0d209e0", "1536766768598-e09213fdcf22", "1463335361701-e90f4c5045d0",
    "1526392195523-1f40e4e78117", "1617297873650-aef8f4e00b9b", "1727179297202-b1032c0f37eb"
];

def has_any(text: str, words: list[str]) -> bool {
    for w in words {
        if w in text {
            return True;
        }
    }
    return False;
}

# Rough guess for the regular-person pool: role words first, then common
# Sri Lankan female name endings. Only used when the role has no photo set.
def looks_female(name: str, role: str) -> bool {
    r = role.lower();
    if has_any(r, ["sister", "mother", "bride", "wife", "daughter", "aunt", "maid", "waitress", "actress", "lady", "woman", "girl", "nun", "grandmother"]) {
        return True;
    }
    if has_any(r, ["brother", "father", "groom", "husband", "son", "uncle", "man", "boy", "monk", "grandfather"]) {
        return False;
    }
    n = name.lower().strip();
    return n.endswith("i") or n.endswith("ee") or n.endswith("sha") or n.endswith("ni") or n.endswith("ka");
}

def pick(pool: list[str], name: str, idx: int) -> str {
    return BASE + pool[(idx + len(name)) % len(pool)] + SIZE;
}

def:pub photo_for(name: str, role: str, idx: int) -> str {
    r = role.lower();
    if has_any(r, ["police", "officer", "inspector", "constable", "sergeant", "detective", "cop"]) {
        return pick(OFFICER, name, idx);
    }
    if has_any(r, ["guard", "security", "watchman", "bouncer", "bodyguard", "gatekeeper"]) {
        return pick(GUARD, name, idx);
    }
    if has_any(r, ["chef", "cook", "caterer", "baker", "kitchen", "waiter"]) {
        return pick(CHEF, name, idx);
    }
    if has_any(r, ["doctor", "nurse", "physician", "surgeon", "pharmacist", "medic"]) {
        return pick(DOCTOR, name, idx);
    }
    if has_any(r, ["photographer", "camera", "journalist", "reporter", "videographer"]) {
        return pick(PHOTOGRAPHER, name, idx);
    }
    if has_any(r, ["driver", "chauffeur", "taxi", "tuk", "conductor"]) {
        return pick(DRIVER, name, idx);
    }
    if has_any(r, ["manager", "owner", "boss", "ceo", "director", "businessman", "accountant", "lawyer", "planner", "investor", "partner"]) {
        return pick(BUSINESS, name, idx);
    }
    return pick(WOMEN if looks_female(name, role) else MEN, name, idx);
}
