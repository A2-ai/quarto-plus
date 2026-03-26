# quarto-plus

## Installation 

External installation can be performed by changing directory to the quarto-report template directory in terminal (e.g., ~/Project/report/quarto-report) and by entering the following:

`quarto add A2-ai/quarto-plus`

Please follow the terminal prompts and enter input appropriately. 

## Usage

The quarto-plus extension is implemented as a combination of lua filters and shortcodes in Quarto. Once installed, using the extension is fairly intuitive.

### Automatic Filters

Upon rendering, certain filters automatically run without any user interaction. Within this extension, one filter specifically targets headers.

The header filter parses the intermediate document for empty level 1 headers and removes them to prevent unwanted headers in the rendered Microsoft Word document. For the remaining headers, a tab character is inserted before each one in the rendered Word document to maintain formatting compliance.

Header indentation can be disabled by setting `indent-headers` to `false` in the YAML frontmatter. Default is `true`.

### Markdown Divs

The quarto-plus extension utilizes markdown divs to create certain elements or fields in the rendered Microsoft Word document. Creating the element or field is as simple as opening and closing the div at the desired location within the Quarto document.

#### Table of Contents

To create a table of contents field in the Microsoft Word document, please place the following div at an appropriate location:

`::: .toc`

`:::`

The table of contents can be configured with the following YAML frontmatter keys:

* `toc-levels` sets the heading level range to include. Default is `"1-3"`.
* `toc-style-map` allows mapping custom styles to TOC levels. Accepts a list of style/level pairs:
  ```yaml
  toc-style-map:
    - style: "CustomHeading"
      level: 1
    - style: "AnotherStyle"
      level: 2
  ```

#### List of Figures

To create a list of figures field in the Microsoft Word document, please place the following div at an appropriate location:

`::: .list_of_figures`

`:::`

#### List of Tables

To create a list of tables field in the Microsoft Word document, please place the following div at an appropriate location:

`::: .list_of_tables`

`:::`

#### Terms and Abbreviations

The quarto-plus extension allows a user to define abbreviations, acronyms, or terms in an abbreviations.tex file, that will be referenced during document drafting. The path to this file can be configured with the `abbreviations-file` frontmatter key (default is `"abbreviations.tex"` in the quarto project root). Unmatched glossary terms are logged to the file specified by `unmatched-glossary-log` (default is `"unmatched_glossary_terms.log"`).

The following is a line from the `abbreviations.tex` file:

`\newacronym{AUC0-24,ss}{AUC~0-24,ss~}{area under the concentration curve from time 0 to 24 hours at steady-state}`

The first set of curly braces `{AUC0-24,ss}` is the abbreviation's/acronym's/term's sorting key, a value used to sort the list of abbreviations/acronyms/terms. 

The second set of curly braces `{AUC~0-24,ss~}` is the pandoc-appreciated, markdown representation of the abbreviation/acronym/term. This value is what is inserted into the rendered Microsoft Word document as the abbreviation/acronym/term. Markdown representation is used to enable sub- and superscripts among abbreviations/acronyms/terms. 

The third set of curly braces `{area under the concentration curve from time 0 to 24 hours at steady-state}` is the look up value (i.e., definition) for each abbreviation/acronym/term. This definition is what is inserted into the rendered Microsoft Word document upon first use of each abbreviation/acronym/term.

While drafting, the user can use the following: `\gls{}`, `\glspl{}`, `\Gls{}`, and `\Glspl{}` commands to reference these defined values:

- The `\gls{}` command is used to reference the abbreviation/acronym/term.

- The `\glspl{}` command is used to reference the abbreviation/acronym/term, then pluralize it. 

- The `\Gls{}` command is used to reference the abbreviation/acronym/term, then capitalize the first character.

- The `\Glspl{}` command is used to reference the abbreviation/acronym/term, capitalize the first character, then pluralize it. 

Finally, a user can insert a list of abbreviations/acronyms/terms in the rendered Microsoft Word document by placing the following div at an appropriate location:

`::: .abbreviations`

`:::`

abbreviations/acronyms/terms listed within the table will only include those that were referenced using one of the `\gls{}`, `\glspl{}`, `\Gls{}`, or `\Glspl{}` commands

### Shortcodes

The quarto-plus extension utilizes Quarto shortcodes to create or emulate certain elements or fields in the rendered Microsoft Word document. For more on shortcodes, please see: https://quarto.org/docs/authoring/shortcodes.html

The following shortcodes are available for use from this extension:

- `{{< style >}}`
- `{{< fig_caption >}}`
- `{{< tbl_caption >}}`
- `{{< crossref >}}`

The `{{< style >}}` shortcode allows a user to provide in-line customization of text to a given Microsoft Word Style. To use the shortcode, provide the Style and the text for the Style to be applied to, like so:

`{{< style "Caption" "This should be in caption style" >}}`

The `{{< fig_caption >}}` and `{{< tbl_caption >}}` shortcodes allow a user to generate a figure or table caption in the rendered Microsoft Word document. The Word style applied to captions can be configured with `caption-style-figure` and `caption-style-table` in the YAML frontmatter (both default to `"Caption"`). To use the shortcodes, provide the desired bookmark ID and caption text, like so:

`{{< fig_caption "Figure 1" "This is a simple concentration-time figure" >}}`
`{{< tbl_caption "Table 1" "This is a simple summary table" >}}`

The `{{< crossref >}}` shortcode allows a user to cross-reference figure or table captions in the rendered Microsoft Word document. To use the shortcode, provide the bookmark ID of the caption, like so:

`{{< crossref "Table 1" >}}`

## Examples

Please see the example.qmd for interactable examples!
