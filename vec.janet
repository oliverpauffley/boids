(use judge)

(defn vec/length [vec]
  (math/sqrt (sum (map |(* $ $) vec))))

(test (vec/length [3 4]) 5)

(defn vec/scale [factor vec]
  (map |(* $ factor) vec))

(test (vec/scale 5 [1 2 3]) @[5 10 15])


(defn vec/+ [& vs]
  (map |(+ ;$&) ;vs))

(test (vec/+ [1 2 3] [4 5 6]) @[5 7 9])
(test (vec/+ [1 2 3] [4 5 6] [7 8 9]) @[12 15 18])

(defn vec/clockwise-perp [v]
  (let [[x y] v]
    [y (- x)]))

(test (vec/clockwise-perp [3 4]) [4 -3])

(defn vec/normalize [v]
  (vec/scale (/ 1 (vec/length v)) v))

(test (vec/normalize [5 0]) @[1 0])
(test (vec/normalize [0 5]) @[0 1])
(test (vec/normalize [3 4]) @[0.60000000000000009 0.8])


(defn vec/anticlockwise-perp [v]
  (let [[x y] v]
    [(- y) x]))

(test (vec/anticlockwise-perp [3 4]) [-4 3])
