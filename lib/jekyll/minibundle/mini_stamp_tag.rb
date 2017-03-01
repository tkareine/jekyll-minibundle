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
      raise ArgumentError, 'Missing asset source and destination for ministamp tag; specify value such as "_assets/source.css assets/destination.css" as the argument' if args.empty?

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
      source, destination = str.split(/\s+/, 3)[0, 2]

      raise ArgumentError, 'Missing asset destination for ministamp tag; specify value such as "assets/destination.css" after asset source argument, separated with a space' unless destination

      {
        'source_path'      => source,
        'destination_path' => destination,
        'use_template'     => false
      }
    end

    def parse_hash_argument(hash)
      source = hash.fetch('source', '').to_s
      destination = hash.fetch('destination', '').to_s

      raise ArgumentError, 'Missing asset source for ministamp tag; specify Hash entry such as "source: _assets/site.css"' if source.empty?
      raise ArgumentError, 'Missing asset destination for ministamp tag; specify Hash entry such as "destination: assets/site.css"' if destination.empty?

      {
        'source_path'      => source,
        'destination_path' => destination,
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
