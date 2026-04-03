; extends

((call_expression
   function: (identifier) @_tag
   arguments: (template_string
     (string_fragment) @injection.content))
 (#eq? @_tag "sql")
 (#set! injection.language "sql")
 (#set! injection.combined))

((call_expression
   function: (identifier) @_tag
   arguments: (template_string
     (string_fragment) @injection.content
     (template_substitution)
     (string_fragment) @injection.content))
 (#eq? @_tag "sql")
 (#set! injection.language "sql")
 (#set! injection.combined))

((call_expression
   function: (identifier) @_tag
   arguments: (template_string
     (string_fragment) @injection.content
     (template_substitution)
     (string_fragment) @injection.content
     (template_substitution)
     (string_fragment) @injection.content))
 (#eq? @_tag "sql")
 (#set! injection.language "sql")
 (#set! injection.combined))
