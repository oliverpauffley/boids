(use jaylib)
(use judge)
(use ./vec)

(def gray [255 255 255])
(def boid-num 20)
(def boid-width 10)
(def boid-length 20)
(def boid-colour :black)
(def background :ray-white)

(def screen-size 1000)
(def fps 60)

# Boid functions

(defn new-boid [x y]
  @{:pos [x y]
    :velocity [0 0]})

(defn draw-boid [{:pos p :velocity v}]
  (let [dir (if (zero? (vec/length v))
              [0 -1]
              (vec/normalize v))
        p1 (vec/+ p
                          (vec/scale (/ boid-length 2) dir))
        p2 (vec/+ p
                          (vec/scale (- (/ boid-length 2)) dir)
                          (vec/scale (/ boid-width 2) (vec/anticlockwise-perp dir)))
        p3 (vec/+ p
                          (vec/scale (- (/ boid-length 2)) dir)
                          (vec/scale (/ boid-width 2) (vec/clockwise-perp dir)))]
    (draw-triangle p1 p3 p2 boid-colour)))

(defn draw-boids [boids]
  (each boid boids
    (draw-boid boid)))



(defn update-boids [boids]
  )


(defn main [&args]
  (init-window screen-size screen-size "Boids")
  (set-target-fps fps)
  (hide-cursor)
  (let
    [boids (seq [:repeat boid-num]
             (new-boid
               (math/floor (* screen-size (math/random)))
               (math/floor (* screen-size (math/random)))))]
    (while (not (window-should-close))
      (begin-drawing)
      (clear-background background)
      (draw-boids boids)
      (end-drawing))

  (close-window)))
