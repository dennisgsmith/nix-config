;; extends

(
  (call_expression
    function: (identifier) @fn
    arguments: (arguments
      (template_string
        (string_fragment) @injection.content)
      .
      (_)?))
  (#match? @fn "^(_exec|exec|transact)$")
  (#set! injection.language "sql")
)

(
  (call_expression
    function: (identifier) @fn
    arguments: (arguments
      (string
        (string_fragment) @injection.content)
      .
      (_)?))
  (#match? @fn "^(_exec|exec|transact)$")
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (template_string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (lexical_declaration
      (variable_declarator
        value: (await_expression
          (call_expression
            function: (identifier) @fn
            arguments: (arguments
              (identifier) @arg
              . 
              (_)?))))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (template_string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (expression_statement
      (await_expression
        (call_expression
          function: (identifier) @fn
          arguments: (arguments
            (identifier) @arg
            .
            (_)?)))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (template_string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (lexical_declaration
      (variable_declarator
        value: (call_expression
          function: (identifier) @fn
          arguments: (arguments
            (identifier) @arg
            .
            (_)?)))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (template_string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (expression_statement
      (call_expression
        function: (identifier) @fn
        arguments: (arguments
          (identifier) @arg
          .
          (_)?))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (lexical_declaration
      (variable_declarator
        value: (await_expression
          (call_expression
            function: (identifier) @fn
            arguments: (arguments
              (identifier) @arg
              .
              (_)?))))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (expression_statement
      (await_expression
        (call_expression
          function: (identifier) @fn
          arguments: (arguments
            (identifier) @arg
            .
            (_)?)))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (lexical_declaration
      (variable_declarator
        value: (call_expression
          function: (identifier) @fn
          arguments: (arguments
            (identifier) @arg
            .
            (_)?)))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)

(
  (statement_block
    (lexical_declaration
      (variable_declarator
        name: (identifier) @sql_var
        value: (string
          (string_fragment) @injection.content)))
    .
    (_)* 
    .
    (expression_statement
      (call_expression
        function: (identifier) @fn
        arguments: (arguments
          (identifier) @arg
          .
          (_)?))))
  (#match? @fn "^(_exec|exec|transact)$")
  (#eq? @sql_var @arg)
  (#set! injection.language "sql")
)
