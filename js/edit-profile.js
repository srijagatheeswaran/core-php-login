$(document).ready(function () {
    const token = localStorage.getItem("token");

    if (!token) {
        alert("Please log in first.");
        window.location.href = "index.html";
        return;
    }

    $.ajax({
        url: "php/profile.php",
        type: "GET",
        headers: { "Authorization": token},
        success: function (res) {
            if (res.status === "success") {
                const user = res.user;
                $("#username").val(user.username);
                $("#email").val(user.email);
                $("#location").val(user.location || "");
                $("#phone").val(user.phone || "");
                if (user.profile_image) {
                    $("#previewImage").attr("src", user.profile_image).show();
                }
                $('.loader').hide();
            } else {
                window.location.href = "index.html";
            }
        }
    });

    $("#profileImage").on("change", function () {
        $("#messageBox").text('');
        $("#previewImage").hide();
    const file = this.files[0];
    const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"];
    const maxSizeMB = 2;

    if (file) {
        if (!allowedTypes.includes(file.type)) {
            $("#messageBox").text("Only JPG, PNG, GIF, or WEBP images are allowed.")
                .removeClass().addClass("text-danger mt-2 text-center");
            $(this).val(""); 
            $("#previewImage").hide();
            return;
        }

        if (file.size > maxSizeMB * 1024 * 1024) {
            $("#messageBox").text("Image size must be less than 2MB.")
                .removeClass().addClass("text-danger mt-2 text-center");
            $(this).val(""); 
            $("#previewImage").hide();
            return;
        }

        $("#previewImage").attr("src", URL.createObjectURL(file)).show();
    }
});

    $("#editProfileForm").on("submit", function (e) {
        e.preventDefault();

        const username = $("#username").val().trim();
        const email = $("#email").val().trim();
        const phone = $("#phone").val().trim();
        const location = $("#location").val().trim();
        const profileImage = $("#profileImage")[0].files[0];

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        let hasError = false;
        let errorMsg = "";

        if (!username) {
            errorMsg = "Username is required.";
            hasError = true;
        } else if (!email) {
            errorMsg = "Email is required.";
            hasError = true;
        } else if (!emailRegex.test(email)) {
            errorMsg = "Invalid email format.";
            hasError = true;
        } else if (phone && !/^[0-9+\-\s()]+$/.test(phone)) {
            errorMsg = "Invalid phone number format.";
            hasError = true;
        }

        if (hasError) {
            $("#messageBox")
                .text(errorMsg)
                .removeClass()
                .addClass("text-danger mt-2 text-center");
            return;
        }

        // If validation passes
        const formData = new FormData(this);
        const token = localStorage.getItem("token");
        $('.loader').show();

        $.ajax({
            url: "php/edit-profile.php",
            type: "POST",
            headers: { "Authorization": token },
            data: formData,
            processData: false,
            contentType: false,
            success: function (res) {
                $("#messageBox")
                    .text(res.message)
                    .removeClass()
                    .addClass(res.status === "success" ? "text-success mt-2 text-center" : "text-danger mt-2 text-center");
                $('.loader').hide();

            },
            error: function (err) {
                console.error(err);
                $("#messageBox").text("Update failed").addClass("text-danger mt-2 text-center");
                $('.loader').hide();

            }
        });
    });
});
