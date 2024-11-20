return {
    "giuxtaposition/blink-cmp-copilot",
    enabled = true,
    specs = {
        {
            "blink.cmp",
            optional = true,
            opts = {
                sources = {
                    providers = {
                        copilot = { name = "copilot", module = "blink-cmp-copilot" },
                    },
                    completion = {
                        enabled_providers = { "copilot" },
                    },
                },
            },
        },
    },
}
