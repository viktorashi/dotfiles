return {
  "chrisgrieser/nvim-spider",
  opts = {
    skipInsignificantPunctuation = false,
    consistentOperatorPending = true,
  },
  keys = {
    {
      "w",
      function() require("spider").motion("w") end,
      mode = { "n", "o", "x" },
      desc = "Move to start of next of word",
    },
    {
      "e",
      function() require("spider").motion("e") end,
      mode = { "n", "o", "x" },
      desc = "Move to end of word",
    },
    {
      "b",
      function() require("spider").motion("b") end,
      mode = { "n", "o", "x" },
      desc = "Move to start of previous word",
    },
  },
}
