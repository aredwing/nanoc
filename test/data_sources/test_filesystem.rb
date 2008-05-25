require 'helper'

class Nanoc::DataSources::FilesystemTest < Test::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  # Test preparation

  def test_setup
    in_dir %w{ tmp } do
      create_site('site')
      in_dir %w{ site } do
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))

        # Remove files to make sure they are recreated

        FileUtils.remove_entry_secure('content/content.txt')
        FileUtils.remove_entry_secure('content/content.yaml')

        FileUtils.remove_entry_secure('meta.yaml')

        FileUtils.remove_entry_secure('templates/default/default.txt')
        FileUtils.remove_entry_secure('templates/default/default.yaml')

        FileUtils.remove_entry_secure('layouts/default/default.erb')
        FileUtils.remove_entry_secure('layouts/default/default.yaml')

        FileUtils.remove_entry_secure('lib/default.rb')

        # Recreate files

        site.data_source.loading { site.data_source.setup {} }

        # Check whether files have been recreated

        assert(File.directory?('content/'))
        assert(File.file?('content/content.txt'))
        assert(File.file?('content/content.yaml'))

        assert(File.file?('meta.yaml'))

        assert(File.directory?('templates/'))
        assert(File.directory?('templates/default/'))
        assert(File.file?('templates/default/default.txt'))
        assert(File.file?('templates/default/default.yaml'))

        assert(File.directory?('layouts/'))
        assert(File.directory?('layouts/default/'))
        assert(File.file?('layouts/default/default.erb'))
        assert(File.file?('layouts/default/default.yaml'))

        assert(File.directory?('lib/'))
        assert(File.file?('lib/default.rb'))
      end
    end
  end

  # Test pages

  def test_pages
    with_site_fixture 'empty_site' do |site|
      site.load_data

      assert_nothing_raised do
        assert_equal([ 'My New Homepage' ], site.pages.map { |page| page.attribute_named(:title) })
      end
    end
  end

  def test_save_page
    in_dir %w{ tmp } do
      # Create site
      create_site('site')

      in_dir %w{ site } do
        # Load site
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))
        site.load_data

        # Check pages
        assert_equal(1, site.pages.size)
        old_page = site.pages[0]

        # Create page
        new_page = Nanoc::Page.new('Hello, I am a noob.', { :foo => 'bar' }, '/noob/')
        site.data_source.save_page(new_page)
        site.load_data(true)

        # Check pages
        assert_equal(2, site.pages.size)

        # Update page
        old_page.attributes = { :xyzzy => 'abba' }
        site.data_source.save_page(old_page)
        site.load_data(true)

        # Check pages
        assert_equal(2, site.pages.size)
        assert(site.pages.any? { |p| p.attribute_named(:xyzzy) == 'abba' })
      end
    end
  end

  def test_move_page
    # TODO implement
  end

  def test_delete_page
    # TODO implement
  end

  # Test page defaults

  def test_page_defaults
    with_site_fixture 'empty_site' do |site|
      site.load_data

      assert_nothing_raised do
        assert_equal('html', site.page_defaults.attributes[:extension])
      end
    end
  end

  def test_save_page_defaults
    in_dir %w{ tmp } do
      # Create site
      create_site('site')

      in_dir %w{ site } do
        # Load site
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))
        site.load_data

        assert_nothing_raised do
          # Get page defaults
          page_defaults = site.page_defaults

          # Update page defaults
          page_defaults.attributes[:extension] = 'php' # eww, php! :D
          site.data_source.save_page_defaults(page_defaults)
          site.load_data(true)

          # Check page defaults
          assert_equal('php', site.page_defaults.attributes[:extension])
        end
      end
    end
  end

  # Test templates

  def test_templates
    with_site_fixture 'empty_site' do |site|
      site.load_data

      assert_nothing_raised do
        # Find template
        templates = site.templates

        # Check number of templates
        assert_equal(1, templates.size)

        # Check template attributes
        assert_equal('default', templates[0].name)
        assert_equal("This is a new page. Please edit me!\n", templates[0].page_content)
      end
    end
  end

  def test_save_template
    # TODO implement
  end

  def test_move_template
    # TODO implement
  end

  def test_delete_template
    # TODO implement
  end

  # Test layouts

  def test_layouts
    with_site_fixture 'empty_site' do |site|
      site.load_data

      assert_nothing_raised do
        layout = site.layouts[0]

        assert_equal('/default/', layout.path)
        assert_equal('.erb', layout.attribute_named(:extension))
        assert(layout.content.include?('<title><%= @page[:title] %></title>'))
      end
    end
  end

  def test_save_layout
    # TODO implement
  end

  def test_move_layout
    # TODO implement
  end

  def test_delete_layout
    # TODO implement
  end

  # Test code

  def test_code
    with_site_fixture 'empty_site' do |site|
      site.load_data

      assert_nothing_raised do
        assert_match(/# All files in the 'lib' directory will be loaded/, site.code.data)
      end
    end
  end

  def test_save_code
    # TODO implement
  end

  # Test creating data

  # FIXME outdated, remove
  def test_create_page
    in_dir %w{ tmp } do
      create_site('site')
      in_dir %w{ site } do
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))

        assert_nothing_raised()   { create_page('test') }
        assert_raise(SystemExit)  { create_page('test') }

        assert_nothing_raised()   { create_page('foo/bar') }
        assert_raise(SystemExit)  { create_page('foo/bar') }

        assert(File.directory?('content/test/'))
        assert(File.file?('content/test/test.txt'))
        assert(File.file?('content/test/test.yaml'))

        assert(File.directory?('content/foo/bar/'))
        assert(File.file?('content/foo/bar/bar.txt'))
        assert(File.file?('content/foo/bar/bar.yaml'))
      end
    end
  end

  # FIXME outdated, remove
  def test_create_layout
    in_dir %w{ tmp } do
      create_site('site')
      in_dir %w{ site } do  
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))

        assert_nothing_raised()   { create_layout('test') }
        assert_raise(SystemExit)  { create_layout('test') }

        assert(File.file?('layouts/test/test.erb'))
        assert(File.file?('layouts/test/test.yaml'))
      end
    end
  end

  # Miscellaneous

  def test_html_escape
    in_dir %w{ tmp } do
      create_site('site')

      in_dir %w{ site } do
        File.open('content/content.yaml', 'w') do |io|
          io << %q{filters_pre: [ 'erb' ]} + "\n"
          io << %q{title:       "<Hello>"} + "\n"
        end
        File.open('content/content.txt', 'w') { |io| io << "<h1><%= h @page.title %></h1>" }

        site = Nanoc::Site.new(YAML.load_file('config.yaml'))

        assert_nothing_raised() { site.compiler.run }
        assert_nothing_raised() { site.compiler.run }

        assert(File.file?('output/index.html'))
        assert_match(/<h1>&lt;Hello&gt;<\/h1>/, File.read('output/index.html'))
      end
    end
  end

  def test_compile_site_with_file_object
    with_site_fixture 'site_with_file_object' do |site|
      assert_nothing_raised() { site.compiler.run }

      assert(File.file?('output/index.html'))
      assert_equal(1, Dir[File.join('output', '*')].size)
      assert(File.read('output/index.html').include?("This page was last modified at #{File.new('content/content.erb').mtime}."))
    end
  end

  def test_compile_site_with_backup_files
    with_site_fixture 'site_with_backup_files' do |site|
      File.open('content/content.txt~', 'w') { |io| }
      File.open('layouts/default.erb~', 'w') { |io| }

      assert_nothing_raised() { site.compiler.run }
      assert_nothing_raised() { site.compiler.run }

      FileUtils.remove_entry_secure 'content/content.txt~' if File.exist?('content/content.txt~')
      FileUtils.remove_entry_secure 'layouts/default.erb~' if File.exist?('layouts/default.erb~')
    end
  end

  def test_compile_site_with_new_layout_structure
    with_site_fixture 'site_with_new_layout_structure' do |site|
      assert_nothing_raised() { site.compiler.run }
      assert_nothing_raised() { site.compiler.run }

      assert(File.file?('output/index.html'))
      assert_equal(1, Dir[File.join('output', '*')].size)
      assert(File.read('output/index.html').include?('<div class="supercool">Blah blah blah this is a page blah blah blah.</div>'))
    end
  end

  def test_compile_outdated_site
    # Threshold for mtimes in which files will be considered the same
    threshold = 2.0

    in_dir %w{ tmp } do
      create_site('site')

      in_dir %w{ site } do
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))

        # Get timestamps
        distant_past = Time.parse('1992-10-14')
        recent_past  = Time.parse('1998-05-18')
        now          = Time.now

        ########## INITIAL OUTPUT FILE GENERATION

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        ########## EVERYTHING UP TO DATE

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (shouldn't have changed)
        assert((recent_past - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT CONTENT AND META FILES

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(now,          now,          'content/content.txt')
        File.utime(now,          now,          'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT META FILE

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(now,          now,          'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT CONTENT FILE

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(now,          now,          'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT LAYOUT CONTENT FILE

        # Update file mtimes
        File.utime(now,          now,          'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT LAYOUT META FILE

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(now,          now,          'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT PAGE DEFAULTS

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(now,          now,          'meta.yaml')
        File.utime(distant_past, distant_past, 'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)

        ########## RECENT CODE

        # Update file mtimes
        File.utime(distant_past, distant_past, 'layouts/default/default.erb')
        File.utime(distant_past, distant_past, 'layouts/default/default.yaml')
        File.utime(distant_past, distant_past, 'content/content.txt')
        File.utime(distant_past, distant_past, 'content/content.yaml')
        File.utime(distant_past, distant_past, 'meta.yaml')
        File.utime(now,          now,          'lib/default.rb')
        File.utime(recent_past,  recent_past,  'output/index.html')

        # Compile
        site.load_data(true)
        assert_nothing_raised() { site.compiler.run }

        # Check compiled file's mtime (should be now)
        assert((now - File.new('output/index.html').mtime).abs < threshold)
      end
    end
  end

  def test_compile_huge_site
    in_dir %w{ tmp } do
      create_site('site')
  
      in_dir %w{ site } do
        
        # Create a lot of pages
        count = Process.getrlimit(Process::RLIMIT_NOFILE)[0] + 5
        count.times do |i|
          FileUtils.mkdir("content/#{i}")
          File.open("content/#{i}/#{i}.html", 'w') { |io| io << "This is page #{i}." }
          File.open("content/#{i}/#{i}.yaml", 'w') { |io| io << "title: Page #{i}"   }
        end
  
        # Load and compile site
        site = Nanoc::Site.new(YAML.load_file('config.yaml'))
        assert_nothing_raised() { site.compiler.run }
      end
    end
  end

end
