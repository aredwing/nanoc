class Nanoc::Int::ItemTest < Nanoc::TestCase
  def test_initialize_with_attributes_with_string_keys
    item = Nanoc::Int::Item.new('foo', { 'abc' => 'xyz' }, '/foo/')

    assert_equal nil,   item.attributes['abc']
    assert_equal 'xyz', item.attributes[:abc]
  end

  def test_reference
    item = Nanoc::Int::Item.new(
      'content',
      { one: 'one in item' },
      '/path/'
    )

    assert_equal([:item, '/path/'], item.reference)
  end

  def test_attributes
    item = Nanoc::Int::Item.new('content', { 'one' => 'one in item' }, '/path/')
    assert_equal({ one: 'one in item' }, item.attributes)
  end

  def test_compiled_content_with_default_rep_and_default_snapshot
    # Mock rep
    rep = Object.new
    def rep.name
      :default
    end
    def rep.compiled_content(params)
      "content at #{params[:snapshot].inspect}"
    end

    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([rep])

    # Check
    assert_equal 'content at nil', item.compiled_content
  end

  def test_compiled_content_with_custom_rep_and_default_snapshot
    # Mock reps
    rep = Object.new
    def rep.name
      :foo
    end
    def rep.compiled_content(params)
      "content at #{params[:snapshot].inspect}"
    end

    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([rep])

    # Check
    assert_equal 'content at nil', item.compiled_content(rep: :foo)
  end

  def test_compiled_content_with_default_rep_and_custom_snapshot
    # Mock reps
    rep = Object.new
    def rep.name
      :default
    end
    def rep.compiled_content(params)
      "content at #{params[:snapshot].inspect}"
    end

    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([rep])

    # Check
    assert_equal 'content at :blah', item.compiled_content(snapshot: :blah)
  end

  def test_compiled_content_with_custom_nonexistant_rep
    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([])

    # Check
    assert_raises(Nanoc::Int::Errors::Generic) do
      item.compiled_content(rep: :lkasdhflahgwfe)
    end
  end

  def test_path_with_default_rep
    # Mock reps
    rep = mock
    rep.expects(:name).returns(:default)
    rep.expects(:path).returns('the correct path')

    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([rep])

    # Check
    assert_equal 'the correct path', item.path
  end

  def test_path_with_custom_rep
    # Mock reps
    rep = mock
    rep.expects(:name).returns(:moo)
    rep.expects(:path).returns('the correct path')

    # Mock item
    item = Nanoc::Int::Item.new('foo', {}, '/foo')
    item.expects(:reps).returns([rep])

    # Check
    assert_equal 'the correct path', item.path(rep: :moo)
  end

  def test_freeze_should_disallow_changes
    item = Nanoc::Int::Item.new('foo', { a: { b: 123 } }, '/foo/')
    item.freeze

    assert_raises_frozen_error do
      item.attributes[:abc] = '123'
    end

    assert_raises_frozen_error do
      item.attributes[:a][:b] = '456'
    end
  end

  def test_dump_and_load
    item = Nanoc::Int::Item.new(
      'foobar',
      { a: { b: 123 } },
      '/foo/')

    item = Marshal.load(Marshal.dump(item))

    assert_equal Nanoc::Identifier.new('/foo/'), item.identifier
    assert_equal 'foobar', item.raw_content
    assert_equal({ a: { b: 123 } }, item.attributes)
  end
end
