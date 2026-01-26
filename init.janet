(use jaylib)
(use judge)
(use ./vec)

(def gray [255 255 255])
(def boid-num 40)
(def boid-width 10)
(def boid-length 20)
(def boid-colour :black)
(def background :ray-white)
(def max-velocity 10)
(def seperation-distance 10)
(def seperation-factor 1)
(def cohesion-factor 200)
(def alignment-factor 8)

(def screen-size 1000)
(def fps 30)

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

(defn seperation [boid boids]
  "boids try and avoid other boids"
  (let [vs
        (seq [boid2 :in boids
              :let [offset (vec/- (boid :pos) (boid2 :pos))]
              :let [dist (vec/length offset)]
              :when (and (not (deep= boid boid2)) (< dist seperation-distance))]
          offset)]
    (vec/scale (/ seperation-factor)
               (reduce vec/+ [0 0] vs))))

(test (seperation
        {:pos [1 2] :velocity [0 0]}
        [{:pos [1 3] :velocity [0 0]} {:pos [2 5] :velocity [0 0]}])
      @[-1 -4])

(defn cohesion [boid boids]
  "boids fly towards the average position of other boids"
  (let [sum-pos (reduce vec/+ [0 0] (map |($ :pos) boids))
        avg (vec/scale (/ (length boids)) sum-pos)
        dir (vec/- avg (boid :pos))]
    (vec/scale (/ cohesion-factor) dir)))


(test (cohesion
        {:pos [1 2] :velocity [0 0]}
        [@{:pos [1 3] :velocity [0 0]} @{:pos [2 5] :velocity [0 0]}])
  @[0.0025 0.01])

(defn alignment [boid boids]
  "boids should match their velocity to all the other boids"
  (let [sum-vel (reduce vec/+ [0 0] (map |($ :velocity) boids))
        avg (vec/scale (/ (length boids)) sum-vel)
        dir (vec/- avg (boid :velocity))]
    (vec/scale (/ alignment-factor) dir)))


(defn- wall [coord]
  (cond
    (= 0 coord) screen-size
    (= screen-size coord) (- screen-size)
    coord))

(defn walls [boid]
  "avoid the walls"
  (map wall (boid :pos)))

(test (walls {:pos [0 123] :velocity [0 0]}) @[1000 123])
(test (walls {:pos [0 screen-size] :velocity [0 0]}) @[1000 -1000])

(defn update-boids [boids]
  (let [new-pos-boids
        (map |(put $ :pos (vec/+ ($ :pos) ($ :velocity))) boids)]
    (each boid new-pos-boids
      (put boid :velocity (vec/clamp max-velocity
                                     (vec/+
                                       (boid :velocity)
                                       (seperation boid new-pos-boids)
                                       (cohesion boid new-pos-boids)
                                       (alignment boid new-pos-boids)
                                       (walls boid))))))
  boids)

(test (update-boids [@{:pos @[1 2] :velocity @[4 5]} @{:pos [1 3] :velocity @[0 0]}])
  [@{:pos @[5 7] :velocity @[10 10]}
   @{:pos @[1 3]
     :velocity @[-2.365 -0.36500000000000021]}])

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
      (update-boids boids)
      (end-drawing))

    (close-window)))
