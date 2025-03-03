;; Recipe Manager Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-exists (err u101))
(define-constant err-recipe-not-found (err u102))
(define-constant err-invalid-rating (err u103))
(define-constant err-invalid-tip (err u104))
(define-constant minimum-tip u1)

;; Data Types
(define-map recipes
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    ingredients: (string-utf8 1000),
    instructions: (string-utf8 2000),
    total-rating: uint,
    reviews: uint,
    tips-received: uint
  }
)

(define-data-var next-recipe-id uint u1)

;; Events
(define-data-var recipe-created-event (string-ascii 50) "recipe-created")

;; Public Functions
(define-public (create-recipe (title (string-ascii 100)) (ingredients (string-utf8 1000)) (instructions (string-utf8 2000)))
  (let ((recipe-id (var-get next-recipe-id)))
    (map-insert recipes
      { id: recipe-id }
      {
        creator: tx-sender,
        title: title,
        ingredients: ingredients, 
        instructions: instructions,
        total-rating: u0,
        reviews: u0,
        tips-received: u0
      }
    )
    (var-set next-recipe-id (+ recipe-id u1))
    (try! (contract-call? .user-profiles increment-recipes-created tx-sender))
    (print (var-get recipe-created-event))
    (ok recipe-id)
  )
)

(define-public (rate-recipe (recipe-id uint) (rating uint))
  (begin
    (asserts! (and (>= rating u1) (<= rating u5)) (err err-invalid-rating))
    (let ((recipe (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found))))
      (map-set recipes
        { id: recipe-id }
        (merge recipe { 
          total-rating: (+ (get total-rating recipe) (* rating u100)),
          reviews: (+ (get reviews recipe) u1)
        })
      )
      (ok true)
    )
  )
)

(define-public (tip-recipe (recipe-id uint) (amount uint))
  (begin
    (asserts! (>= amount minimum-tip) (err err-invalid-tip))
    (let ((recipe (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found))))
      (try! (contract-call? .user-profiles get-profile (get creator recipe)))
      (try! (contract-call? .mocha-token tip-creator (get creator recipe) amount))
      (map-set recipes
        { id: recipe-id }
        (merge recipe {
          tips-received: (+ (get tips-received recipe) amount)
        })
      )
      (ok true)
    )
  )
)

;; Read Only Functions
(define-read-only (get-recipe (recipe-id uint))
  (ok (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found)))
)

(define-read-only (get-recipe-rating (recipe-id uint))
  (let ((recipe (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found))))
    (if (is-eq (get reviews recipe) u0)
      (ok u0)
      (ok (/ (get total-rating recipe) (get reviews recipe)))
    )
  )
)
