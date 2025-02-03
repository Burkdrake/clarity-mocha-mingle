;; Recipe Manager Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-exists (err u101))
(define-constant err-recipe-not-found (err u102))

;; Data Types
(define-map recipes
  { id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    ingredients: (string-utf8 1000),
    instructions: (string-utf8 2000),
    rating: uint,
    reviews: uint,
    tips-received: uint
  }
)

(define-data-var next-recipe-id uint u1)

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
        rating: u0,
        reviews: u0,
        tips-received: u0
      }
    )
    (var-set next-recipe-id (+ recipe-id u1))
    (ok recipe-id)
  )
)

(define-public (rate-recipe (recipe-id uint) (rating uint))
  (let ((recipe (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found))))
    (map-set recipes
      { id: recipe-id }
      (merge recipe { 
        rating: (+ (get rating recipe) rating),
        reviews: (+ (get reviews recipe) u1)
      })
    )
    (ok true)
  )
)

;; Read Only Functions
(define-read-only (get-recipe (recipe-id uint))
  (ok (unwrap! (map-get? recipes {id: recipe-id}) (err err-recipe-not-found)))
)
