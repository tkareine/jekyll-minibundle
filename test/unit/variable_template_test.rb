# coding: utf-8

require 'support/test_case'
require 'jekyll/minibundle/variable_template'

module Jekyll::Minibundle::Test
  class VariableTemplateTest < TestCase
    VARIABLES = {
      'var1' => 41,
      'var2' => '42',
      'var3' => 43
    }.freeze

    def test_render_single_variable
      assert_equal('41', render('{{var1}}', VARIABLES))
      assert_equal('abc 41 zz', render('abc {{var1}} zz', VARIABLES))
    end

    def test_render_many_variables
      assert_equal('414243', render('{{var1}}{{var2}}{{var3}}', VARIABLES))
      assert_equal('abc 41 42efg43hij', render('abc {{var1}} {{var2}}efg{{var3}}hij', VARIABLES))
    end

    def test_render_single_variable_many_times
      assert_equal('4141', render('{{var1}}{{var1}}', VARIABLES))
    end

    def test_strip_whitespace_around_variable_name
      assert_equal('41 42', render("{{ var1\t}} {{ \n var2\n}}", VARIABLES))
    end

    def test_render_empty_string_for_nil_variable
      assert_equal('', render('{{nosuch}}', VARIABLES))
    end

    def test_variable_name_can_be_anything_but_closing_tag
      assert_equal('42', render('{{ foo {{ 3… } bar }}', 'foo {{ 3… } bar' => 42))
    end

    def test_return_template_without_variables_as_is
      assert_equal('', render('', VARIABLES))
      assert_equal('abc', render('abc', VARIABLES))
    end

    def test_raise_error_if_nil_template
      err = assert_raises(ArgumentError) { VariableTemplate.compile(nil) }
      assert_equal('Nil template', err.to_s)
    end

    def test_raise_error_if_unclosed_open_tag
      err = assert_raises(VariableTemplate::SyntaxError) { VariableTemplate.compile('beg{{var}end') }
      expected = <<-END
Missing closing tag ("}}") for variable opening tag ("{{") at position 5 in template (position highlighted with "@"):
beg{{@var}end
      END
      assert_equal(expected, err.to_s)
    end

    def test_application_to_same_compiled_template_many_times
      template = VariableTemplate.compile('the answer is {{var}}, obviously')
      assert_equal('the answer is 42, obviously', template.render('var' => 42))
      assert_equal('the answer is 21, obviously', template.render('var' => 21))
    end

    def test_nonascii_template_and_variables
      variables = {
        '…first'   => 'after first…',
        'yötön yö' => 'yö'
      }
      actual = render('begin… {{ …first }} middle {{yötön yö}} …end', variables)
      expected = 'begin… after first… middle yö …end'
      assert_equal(expected, actual)
    end

    def test_escapes_with_backslash
      assert_equal('\\', render('\\\\', VARIABLES))
      assert_equal('{', render('\\{', VARIABLES))
      assert_equal('}', render('\\}', VARIABLES))
      assert_equal('\\a', render('\\a', VARIABLES))
      assert_equal('{{var1}}', render('\{{var1}}', VARIABLES))
      assert_equal('{{var1}}', render('{\{var1}}', VARIABLES))
      assert_equal('{{var1}}', render('\{{var1\}}', VARIABLES))
      assert_equal('{{var1}}', render('\{{var1}\}', VARIABLES))
      assert_equal('bar', render('{{foo\\}}', 'foo\\' => 'bar'))
    end

    def test_generator_escapes_text_token
      assert_equal('#{}', render('#{}', {}))
      assert_equal('"hey"', render('"hey"', {}))
      assert_equal("'hey'", render("'hey'", {}))
    end

    def test_generator_escapes_variable_token
      assert_equal('42', render('{{ \\ }}', '\\' => 42))
      assert_equal('42', render("{{ ' }}", "'" => 42))
      assert_equal('42', render('{{ " }}', '"' => 42))
      assert_equal('42', render('{{ #{} }}', '#{}' => 42))
      assert_equal("beg'42'end", render("beg'{{ 'var' }}'end", "'var'" => 42))
    end

    def test_complex_template
      variables = {
        'integer'    => 42,
        'string'     => 'a rather long string',
        'sneaky… \\' => 'clever…'
      }

      template = 'begin "ä\\{\\ö\\\\{{integer}}middle \{{trap}} and {{ string }} also {{ sneaky… \\}} end'
      expected = 'begin "ä{\\ö\\42middle {{trap}} and a rather long string also clever… end'
      actual = render(template, variables)

      assert_equal(expected, actual)
    end

    private

    def render(template, values)
      VariableTemplate.compile(template).render(values)
    end
  end
end
