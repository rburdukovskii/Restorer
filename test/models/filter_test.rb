require "test_helper"

class FilterTest < ActiveSupport::TestCase
  test ".all возвращает хеш фильтров" do
    assert_kind_of Hash, Filter.all
    assert Filter.all.any?
  end

  test ".find возвращает фильтр по slug" do
    filter = Filter.find("bw")
    assert_equal "Ч/Б", filter[:name]
  end

  test ".find возвращает nil для неизвестного фильтра" do
    assert_nil Filter.find("nonexistent")
  end

  test ".slug_valid? проверяет slug" do
    assert Filter.slug_valid?("bw")
    assert_not Filter.slug_valid?("invalid")
  end

  test ".default возвращает original" do
    assert_equal "original", Filter.default
  end

  test "все фильтры имеют name, description, icon, operations" do
    Filter.all.each do |slug, filter|
      assert filter[:name].present?, "#{slug} без name"
      assert filter[:description].present?, "#{slug} без description"
      assert filter[:icon].present?, "#{slug} без icon"
      assert filter[:operations].is_a?(Array), "#{slug} operations не массив"
    end
  end
end