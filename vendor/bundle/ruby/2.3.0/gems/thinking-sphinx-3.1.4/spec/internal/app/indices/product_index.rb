multi_schema = MultiSchema.new

ThinkingSphinx::Index.define :product, :with => :real_time do
  indexes name, :sortable => true

  has category_ids, :type => :integer, :multi => true
end

if multi_schema.active?
  multi_schema.create 'thinking_sphinx'

  ThinkingSphinx::Index.define(:product,
    :name => :product_two, :offset_as => :product_two, :with => :real_time
  ) do
    indexes name, prefixes: true

    set_property min_prefix_len: 1, dict: :keywords

    scope do
      multi_schema.switch :thinking_sphinx
      User
    end
  end

  multi_schema.switch :public
end
