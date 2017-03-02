# coding: utf-8

require 'benchmark/ips'
require 'jekyll/minibundle/variable_template'

VARIABLES = {
  'integer'    => 42,
  'string'     => 'a rather long string',
  'sneaky… \\' => 'clever…'
}.freeze

TEMPLATE = 'begin… {{ integer }} middle \{{escape}} {{ string }} also {{ sneaky… \\}} end'.freeze
EXPECTED = 'begin… 42 middle {{escape}} a rather long string also clever… end'.freeze

raise 'Unexpected template in benchmark' unless Jekyll::Minibundle::VariableTemplate.compile(TEMPLATE).render(VARIABLES) == EXPECTED

Benchmark.ips do |x|
  x.report('compile') do
    Jekyll::Minibundle::VariableTemplate.compile(TEMPLATE)
  end

  template = Jekyll::Minibundle::VariableTemplate.compile(TEMPLATE)

  x.report('render') do
    template.render(VARIABLES)
  end
end
