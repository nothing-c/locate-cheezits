(defun get-target-cheezit-data (x)
  "With the lispified JSON individiual store, return (address-string (in-store pickup curbside) quantity). Made to be mapped across the locations hash from the JSON"
  (list
   (concat (gethash "address_line1" (gethash "mailing_address" (gethash "store" x)))
	   " "
	   (gethash "city" (gethash "mailing_address" (gethash "store" x)))
	   ", "
	   (gethash "state" (gethash "mailing_address" (gethash "store" x)))
	   " "
	   (gethash "postal_code" (gethash "mailing_address" (gethash "store" x))))
   (list
    (gethash "availability_status" (gethash "in_store_only" x))
    (gethash "availability_status" (gethash "order_pickup" x))
    (gethash "availability_status" (gethash "curbside" x)))
   (gethash "location_available_to_promise_quantity" x)))

(defun get-target-cheezits-auto (zip radius)
  "With a zip code (as an int currently, but probably will shift to a string at some point) and a radius int, return the lispified JSON"
  (let ((url-request-method "GET")
	(base-path "https://redsky.target.com/redsky_aggregations/v1/web/fiats_v1")
	(key "9f36aeafbe60771e321a7cc95a78140772ab3e96")
	(sku-number 94877804))
    (switch-to-buffer (url-retrieve-synchronously (format "%s?key=%s&tcin=%d&nearby=%d&radius=%d&include_only_available_stores=true&requested_quantity=1&channel=WEB&page=/p/A-94877804" base-path key sku-number zip radius)))
    (mapcar #'get-target-cheezit-data (gethash "locations" (gethash "fulfillment_fiats" (gethash "data" (json-parse-buffer)))))))

(setq outfile "./cheezit.csv")

;; This should get me plenty of (redundant) coverage
(setq stores
      (append
       (ignore-errors (get-target-cheezits-auto 98101 500))
       (ignore-errors (get-target-cheezits-auto 99201 500))
       (ignore-errors (get-target-cheezits-auto 97201 500))
       (ignore-errors (get-target-cheezits-auto 95814 500))
       (ignore-errors (get-target-cheezits-auto 90001 500))
       (ignore-errors (get-target-cheezits-auto 83702 500))
       (ignore-errors (get-target-cheezits-auto 84101 500))
       (ignore-errors (get-target-cheezits-auto 82601 500))
       (ignore-errors (get-target-cheezits-auto 59101 500))
       (ignore-errors (get-target-cheezits-auto 80202 500))
       (ignore-errors (get-target-cheezits-auto 85001 500))
       (ignore-errors (get-target-cheezits-auto 58701 500))
       (ignore-errors (get-target-cheezits-auto 57104 500))
       (ignore-errors (get-target-cheezits-auto 68502 500))
       (ignore-errors (get-target-cheezits-auto 67202 500))
       (ignore-errors (get-target-cheezits-auto 73102 500))
       (ignore-errors (get-target-cheezits-auto 75102 500))
       (ignore-errors (get-target-cheezits-auto 78201 500))
       (ignore-errors (get-target-cheezits-auto 79901 500))
       (ignore-errors (get-target-cheezits-auto 55401 500))
       (ignore-errors (get-target-cheezits-auto 60601 500))
       (ignore-errors (get-target-cheezits-auto 63101 500))
       (ignore-errors (get-target-cheezits-auto 48201 500))
       (ignore-errors (get-target-cheezits-auto 46201 500))
       (ignore-errors (get-target-cheezits-auto 10001 500))
       (ignore-errors (get-target-cheezits-auto 20001 500))
       (ignore-errors (get-target-cheezits-auto 30303 500))
       (ignore-errors (get-target-cheezits-auto 33101 500))))

(progn (find-file outfile)
       (insert "Addresses\n")
       (mapcar (lambda (x) (insert (concat (car x) "\n"))) (seq-uniq stores (lambda (x y) (string-equal (car x) (car y)))))
       (write-file outfile)
       (kill-buffer))

