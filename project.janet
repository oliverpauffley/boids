(declare-project
  :name "boids"
  :description ```boids in janet.```
  :version "0.0.0"
  :dependencies ["spork" "jaylib" "cmd"])

(declare-executable
  :name "boids"
  :entry "init.janet"
  :install true)
