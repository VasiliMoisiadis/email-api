ENV['RAILS_ENV'] ||= 'test'

require 'rack/test'
require_relative '../minitest_helper'

require_relative '../../lib/email_api/api/api_parser'

# Exclusively tests the Api Parser
class ApiParserTests < MiniTest::Test
  include Rack::Test::Methods

  # Note:
  # - All tests on regarding 'Email Text' test fn `parse_email_text`
  # and test using the 'From' Email Attribute. Impacts all email-based attrs.
  # - All tests on regarding 'Email Array' test fn `parse_email_text_arr`
  # and test using the 'To' Email Attribute. Impacts To, CC, BCC attrs as well.
  # - All tests on regarding 'Simple Content' test fn `parse_email`
  # and test using the 'Subject' Email Attribute. Impacts Content attr as well.

  # Test ApiParser handling nil or empty input
  def test_parser_handles_nil_or_empty
    assert_equal expected_response, ApiParser.parse_email
  end

  # Test ApiParser handling unsupported email text inputs
  def test_parser_handles_unsupported_email_text
    email_text_assert nil, nil
    email_text_assert nil, 123
    email_text_assert nil, {}
    email_text_assert nil, []
  end

  # Test ApiParser handling an empty String as an email text input
  def test_parser_handles_empty_email_text
    empty_string = ''

    email_text_assert empty_string, empty_string
  end

  # Test ApiParser handling miscellaneous text as an email text input
  def test_parser_handles_misc_email_text
    valid_from_name = 'From Name'

    email_text_assert valid_from_name, valid_from_name
  end

  # Test ApiParser handling misc text with whitespace as an email text input
  def test_parser_handles_whitespace_email_text
    valid_from_name = 'From Name'

    email_text_assert '', '    '
    email_text_assert valid_from_name, "    #{valid_from_name}"
    email_text_assert valid_from_name, "#{valid_from_name}    "
    email_text_assert valid_from_name, "    #{valid_from_name}    "
  end

  # Test ApiParser handling restricted symbols before valid text as an email
  # text input
  def test_parser_handles_leading_restricted_email_text
    valid_from_name = 'From Name'

    email_text_assert valid_from_name, ",#{valid_from_name}"
    email_text_assert valid_from_name, ", #{valid_from_name}"
    email_text_assert valid_from_name, ",, #{valid_from_name}"
    email_text_assert valid_from_name, ", , #{valid_from_name}"
    email_text_assert valid_from_name, "<#{valid_from_name}"
    email_text_assert valid_from_name, "< #{valid_from_name}"
    email_text_assert valid_from_name, "<< #{valid_from_name}"
    email_text_assert valid_from_name, "< < #{valid_from_name}"
    email_text_assert valid_from_name, ">#{valid_from_name}"
    email_text_assert valid_from_name, "> #{valid_from_name}"
    email_text_assert valid_from_name, ">> #{valid_from_name}"
    email_text_assert valid_from_name, "> > #{valid_from_name}"
    email_text_assert valid_from_name, ",<<>>,#{valid_from_name}"
    email_text_assert valid_from_name, ",<<>>, #{valid_from_name}"
  end

  # Test ApiParser handling restricted symbols after valid text as an email
  # text input
  def test_parser_handles_trailing_restricted_email_text
    valid_from_name = 'From Name'

    email_text_assert valid_from_name, "#{valid_from_name},"
    email_text_assert valid_from_name, "#{valid_from_name} ,"
    email_text_assert valid_from_name, "#{valid_from_name} ,"
    email_text_assert valid_from_name, "#{valid_from_name} , ,"
    email_text_assert valid_from_name, "#{valid_from_name}<"
    email_text_assert valid_from_name, "#{valid_from_name} <"
    email_text_assert valid_from_name, "#{valid_from_name} <<"
    email_text_assert valid_from_name, "#{valid_from_name} < <"
    email_text_assert valid_from_name, "#{valid_from_name}>"
    email_text_assert valid_from_name, "#{valid_from_name} >"
    email_text_assert valid_from_name, "#{valid_from_name} >>"
    email_text_assert valid_from_name, "#{valid_from_name} > >"
    email_text_assert valid_from_name, "#{valid_from_name},<<>>,"
    email_text_assert valid_from_name, "#{valid_from_name} ,<<>>,"
  end

  # Test ApiParser handling restricted symbols surrounding valid text as an
  # email text input
  def test_parser_handles_surrounding_restricted_email_text
    valid_from_name = 'From Name'

    email_text_assert valid_from_name, ",#{valid_from_name},"
    email_text_assert valid_from_name, ", #{valid_from_name} ,"
    email_text_assert valid_from_name, ",, #{valid_from_name} ,,"
    email_text_assert valid_from_name, ", , #{valid_from_name} , ,"
    email_text_assert valid_from_name, "<#{valid_from_name}<"
    email_text_assert valid_from_name, "< #{valid_from_name} <"
    email_text_assert valid_from_name, "<< #{valid_from_name} <<"
    email_text_assert valid_from_name, "< < #{valid_from_name} < <"
    email_text_assert valid_from_name, ">#{valid_from_name}>"
    email_text_assert valid_from_name, "> #{valid_from_name} >"
    email_text_assert valid_from_name, ">> #{valid_from_name} >>"
    email_text_assert valid_from_name, "> > #{valid_from_name} > >"
    email_text_assert valid_from_name, ",<<>>,#{valid_from_name},<<>>,"
    email_text_assert valid_from_name, ",<<>>, #{valid_from_name} ,<<>>,"
  end

  # Test ApiParser handling restricted symbols mixed in with the valid text
  # as an email text input
  def test_parser_handles_seeded_restricted_email_text
    from_name = 'From Name'

    email_text_assert from_name, 'From> Name'
    email_text_assert from_name, 'Fr<>om Na<>me'
    email_text_assert EmailAddress.new('From', 'Name'), 'From< Name'
    email_text_assert EmailAddress.new('From Na', 'me'), 'Fr>om Na<me'
    email_text_assert EmailAddress.new('Frme', 'om Na'), 'Fr<om Na>me'
    email_text_assert EmailAddress.new('Frme', 'om Na'), 'Fr<<om Na>>me'
    email_text_assert EmailAddress.new('From Na', 'me'), 'Fr>>om Na<<me'
    email_text_assert EmailAddress.new('Fm Name', 'ro'), 'F<ro>m Name'
  end

  # Test ApiParser handling valid email text input
  def test_parser_handles_proper_email_text
    name  = 'From Name'
    email = 'from@name.com'

    email_text_assert EmailAddress.new(name, email), "#{name} <#{email}>"
    email_text_assert EmailAddress.new(name, email), "#{name}<#{email}>"
    email_text_assert EmailAddress.new(name, email), "<#{email}> #{name}"
    email_text_assert EmailAddress.new(name, email), "<#{email}>#{name}"

    email_text_assert EmailAddress.new(email, name), "#{email} <#{name}>"
    email_text_assert EmailAddress.new(email, name), "#{email}<#{name}>"
    email_text_assert EmailAddress.new(email, name), "<#{name}> #{email}"
    email_text_assert EmailAddress.new(email, name), "<#{name}>#{email}"
  end

  # Test ApiParser handling unsupported email array inputs
  def test_parser_handles_unsupported_email_array
    email_array_assert nil, nil
    email_array_assert nil, 123
    email_array_assert nil, {}
    email_array_assert nil, []
  end

  # Test ApiParser handling empty text email array input
  def test_parser_handles_empty_email_array
    empty_string = ''

    email_array_assert empty_string, empty_string
  end

  # Test ApiParser handling text with whitespace as an email array input
  def test_parser_handles_whitespace_email_array
    valid_to_name = 'To Name'

    email_array_assert '', '    '
    email_array_assert valid_to_name, "    #{valid_to_name}"
    email_array_assert valid_to_name, "#{valid_to_name}    "
    email_array_assert valid_to_name, "    #{valid_to_name}    "
  end

  # Test ApiParser handling a single delimiter only as an email array input
  def test_parser_handles_single_delim_no_text_email_array
    email_array_assert ['', ''], ApiParser.email_delim
  end

  # Test ApiParser handling multiple delimiters only as an email array input
  def test_parser_handles_multiple_delim_no_text_email_array
    delim = ApiParser.email_delim

    email_array_assert ['', '', ''], "#{delim}#{delim}"
    email_array_assert ['', '', '', ''], "#{delim}#{delim}#{delim}"
    email_array_assert ['', '', '', '', ''], "#{delim}#{delim}#{delim}#{delim}"
  end

  # Test ApiParser handling a single delimiter with text as an email array input
  def test_parser_handles_no_delim_with_text_email_array
    text = 'To Name'

    email_array_assert text, text
  end

  # Test ApiParser handling multiple delimiters with text as an email array input
  def test_parser_handles_single_delim_with_text_email_array
    text  = 'To Name'
    delim = ApiParser.email_delim

    email_array_assert [text, text], "#{text}#{delim}#{text}"
  end

  # Test ApiParser handling unsupported simple content inputs
  def test_parser_handles_unsupported_simple_content
    simple_content_assert nil, {}
    simple_content_assert nil, []
  end

  # Test ApiParser handling empty text as a simple content input
  def test_parser_handles_empty_simple_content
    simple_content_assert nil, nil
    simple_content_assert nil, ''
  end

  # Test ApiParser handling whitespace with text as a simple content input
  def test_parser_handles_whitespace_no_text_simple_content
    text = 'Simple Content'

    simple_content_assert '    ', '    '
    simple_content_assert "    #{text}", "    #{text}"
    simple_content_assert "#{text}    ", "#{text}    "
    simple_content_assert "    #{text}    ", "    #{text}    "
  end

  # Skeleton assertion used for testing Email Text
  def email_text_assert(exp_val, inp_val)
    exp_hash = {}
    unless exp_val.nil?
      exp_hash['from'] = exp_val
      exp_hash['from'] = EmailAddress.new exp_val unless exp_val.is_a? EmailAddress
    end
    exp = expected_response exp_hash
    assert_equal exp, ApiParser.parse_email(inp_val)
  end

  # Skeleton assertion used for testing Email Text Array
  def email_array_assert(exp_val, inp_val)
    exp_hash = {}
    unless exp_val.nil?
      exp_hash['to'] = exp_val
      exp_hash['to'] = [EmailAddress.new(exp_val)] unless exp_val.is_a?(Array)
      if exp_val.is_a? Array
        exp_hash['to'] = []
        exp_val.each do |val|
          exp_hash['to'].push EmailAddress.new val
        end
      end
    end
    exp = expected_response exp_hash
    assert_equal exp, ApiParser.parse_email(nil, inp_val)
  end

  # Skeleton assertion used for testing Simple Content
  def simple_content_assert(exp_val, inp_val)
    exp_hash            = {}
    exp_hash['subject'] = exp_val unless exp_val.nil?
    exp_hash['content'] = exp_val unless exp_val.nil?
    exp                 = expected_response exp_hash
    assert_equal exp, ApiParser.parse_email(nil, nil, nil, nil, inp_val, inp_val)
  end

  # Builds a testable Email Object
  def expected_response(expected_data = {})
    email_object = EmailObject.new

    # Assign email values
    expected_data.each do |key, value|
      val_hash = value.to_hash if value.respond_to?(:to_hash)

      # Array doesn't implicitly convert to hash automatically
      if val_hash.nil? && value.is_a?(Array)
        val_hash = []
        value.each do |val|
          val_hash.push val.to_hash if val.respond_to?(:to_hash)
        end
      end

      email_object.send("#{key}=", val_hash.nil? ? value : val_hash)
    end

    email_object
  end

end
