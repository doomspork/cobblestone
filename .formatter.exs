[
  inputs: ["*.{ex,exs}", "{lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  export: [
    locals_without_parens: [
      assert_kafee_message_produced: 0,
      assert_kafee_message_produced: 1,
      assert_kafee_message_produced: 2
    ]
  ]
]
