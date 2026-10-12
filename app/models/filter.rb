# app/models/filter.rb
class Filter
  ALL = {
    "original" => {
      name: "Оригинал",
      description: "Без изменений",
      icon: "🖼",
      operations: []
    },
    "bw" => {
      name: "Ч/Б",
      description: "Классическое чёрно-белое",
      icon: "⚫",
      operations: [
        { type: :colorspace, value: "Gray" }
      ]
    },
    "sepia" => {
      name: "Сепия",
      description: "Винтажный тёплый оттенок",
      icon: "📜",
      operations: [
        { type: :sepia, value: 80 }
      ]
    },
    "retro" => {
      name: "Ретро",
      description: "Приглушённые цвета 70-х",
      icon: "📻",
      operations: [
    { type: :modulate, value: { saturation: 60, brightness: 105 } },
    { type: :sepia,    value: 30 },
    { type: :fade,     value: 20 }
  ]
    },
    "sharpen" => {
      name: "Резкость",
      description: "Повышенная детализация",
      icon: "🔍",
      operations: [
        { type: :sharpen, value: "0x2" }
      ]
    },
    "warm" => {
      name: "Тёплый",
      description: "Тёплые тона и мягкий контраст",
      icon: "🌅",
      operations: [
        { type: :modulate, value: { saturation: 115, brightness: 105 } },
        { type: :colorize, value: { color: "#FF6B35", amount: 15 } }
      ]
    },
    "cold" => {
      name: "Холодный",
      description: "Холодные тона, синеватый оттенок",
      icon: "❄️",
      operations: [
        { type: :modulate, value: { saturation: 90 } },
        { type: :colorize, value: { color: "#3B82F6", amount: 15 } }
      ]
    },
    "vivid" => {
      name: "Яркий",
      description: "Насыщенные цвета и контраст",
      icon: "✨",
      operations: [
        { type: :modulate, value: { saturation: 140 } },
        { type: :contrast, value: 1.15 }
      ]
    }
  }.freeze

  def self.all
    ALL
  end

  def self.find(slug)
    ALL[slug.to_s]
  end

  def self.slug_valid?(slug)
    ALL.key?(slug.to_s)
  end

  def self.default
    "original"
  end

  def self.options_for_select
    ALL.map { |slug, f| ["#{f[:icon]} #{f[:name]}", slug] }
  end
end