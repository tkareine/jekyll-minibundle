require 'jekyll/minibundle/files'
require 'jekyll/minibundle/asset_file_registry'
require 'jekyll/minibundle/variable_template_registry'

module Jekyll::Minibundle
  class MiniStampTag < Liquid::Tag
    def initialize(tag_name, text, _tokens)
      super
      @args = parse_arguments(text.strip)
    end

    def render(context)
      stamp_config = get_current_stamp_config(context)
      source_path = stamp_config.fetch('source_path')
      destination_path = stamp_config.fetch('destination_path')
      baseurl = stamp_config.fetch('baseurl')

      site = context.registers.fetch(:site)

      file =
        if Environment.development?(site)
          AssetFileRegistry.register_development_file(site, source_path, destination_path)
        else
          AssetFileRegistry.register_stamp_file(site, source_path, destination_path)
        end

      baseurl + Files.strip_dot_slash_from_path_start(file.destination_path_for_markup)
    end

    private

    def parse_arguments(args)
      raise ArgumentError, 'Missing asset source and destination paths for ministamp tag; specify value such as "_assets/source.css assets/destination.css" as the argument' if args.empty?

      structure = parse_structure(args)

      case structure
      when String
        parse_string_argument(structure)
      when Hash
        parse_hash_argument(structure)
      else
        raise ArgumentError, "Unsupported ministamp tag argument type (#{structure.class}), only String and Hash are supported: #{args}"
      end
    end

    def parse_structure(args)
      ::SafeYAML.load(args)
    rescue => e
      raise ArgumentError, "Failed parsing ministamp tag argument syntax in YAML: #{args.inspect}. Cause: #{e}"
    end

    def parse_string_argument(str)
      source_path, destination_path = str.split(/\s+/, 3)[0, 2]

      unless destination_path
        raise ArgumentError, 'Missing asset destination path for ministamp tag; specify value such as "assets/destination.css" after asset source path argument, separated with a space'
      end

      {
        'source_path'      => source_path,
        'destination_path' => destination_path,
        'use_template'     => false
      }
    end

    def parse_hash_argument(hash)
      source_path = hash.fetch('source_path', '').to_s
      destination_path = hash.fetch('destination_path', '').to_s

      raise ArgumentError, 'Missing asset source path for ministamp tag; specify Hash entry such as "source_path: _assets/site.css"' if source_path.empty?
      raise ArgumentError, 'Missing asset destination path for ministamp tag; specify Hash entry such as "destination_path: assets/site.css"' if destination_path.empty?

      {
        'source_path'      => source_path,
        'destination_path' => destination_path,
        'use_template'     => true
      }
    end

    def get_current_stamp_config(context)
      source_path = @args.fetch('source_path')
      destination_path = @args.fetch('destination_path')

      if @args.fetch('use_template')
        source_path = VariableTemplateRegistry.register_template(source_path).render(context)
        destination_path = VariableTemplateRegistry.register_template(destination_path).render(context)
      end

      baseurl, destination_path = normalize_destination_path(destination_path)

      {
        'baseurl'          => baseurl,
        'source_path'      => source_path,
        'destination_path' => destination_path
      }
    end

    def normalize_destination_path(destination_path)
      if destination_path.start_with?('/')
        ['/', destination_path.sub(%r{\A/+}, '')]
      else
        ['', destination_path]
      end
    end
  end
end

Liquid::Template.register_tag('ministamp', Jekyll::Minibundle::MiniStampTag)
