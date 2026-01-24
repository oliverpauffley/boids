(declare-project
  :name "boids"
  :description ```A simple Janet program```
  :version "0.0.0"
  :dependencies ["spork" "jaylib"])

(declare-executable
  :name "boids"
  :entry "init.janet"
  :install true)
