{application,junit_formatter,
             [{applications,[kernel,stdlib,elixir,logger,xmerl]},
              {description,"An ExUnit.Formatter that produces an XML report of the tests run in the project _build dir.\nIt is a good fit with Jenkins test reporting plugin, for example.\n"},
              {modules,['Elixir.JUnitFormatter',
                        'Elixir.JUnitFormatter.Stats']},
              {registered,[]},
              {vsn,"3.3.0"}]}.
