local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("fig", {
    t(
      "\\begin{figure}[h]\n\\centering\n\\includegraphics[width="
    ),
    i(1, "0.8\\textwidth"),
    t("]{"),
    i(2, "path/to/image"),
    t("}\n\\caption{"),
    i(3, "caption"),
    t("}\n\\label{fig:"),
    i(4, "label"),
    t("}\n\\end{figure}"),
  }),

  s("eq", {
    t("\\begin{equation}\n"),
    i(1, "E=mc^2"),
    t("\n\\end{equation}"),
  }),

  s("itm", {
    t("\\begin{itemize}\n  \\item "),
    i(1),
    t("\n\\end{itemize}"),
  }),
}
