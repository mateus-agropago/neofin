# frozen_string_literal: true

require "test_helper"

class TestNeofin < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Neofin::VERSION, "VERSION should not be nil."

    assert_match(/\A\d+\.\d+\.\d+\z/, ::Neofin::VERSION, "Version should follow X.Y.Z")
  end
end
