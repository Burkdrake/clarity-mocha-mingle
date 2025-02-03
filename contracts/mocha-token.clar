;; Platform Token Contract

;; Token Definition
(define-fungible-token mocha-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))

;; Public Functions
(define-public (tip-creator (recipient principal) (amount uint))
  (begin
    (try! (ft-transfer? mocha-token amount tx-sender recipient))
    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ft-mint? mocha-token amount recipient)
    (err err-owner-only)
  )
)
