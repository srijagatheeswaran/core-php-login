$(document).ready(function () {
    const token = localStorage.getItem("token");

    if (!token) {
        alert("You are not logged in!");
        window.location.href = "index.html";
        return;
    }

    $.ajax({
        url: "php/profile.php",
        type: "GET",
        headers: {
            "Authorization": token
        },
        dataType: "json",
        success: function (data) {
            if (data.status === "success") {
                const user = data.user;
                $("#fullName").text(user.username);
                $("#email").text(user.email);
                $("#username").text(user.username);
                $("#phone").text(user.phone|| "Not provided");
                $("#previewImage").attr("src", user.profile_image || "./assets/user.png");
                $("#location").text(user.location || "Not provided");
                $("#joined").text(formatDate(user.created_at));
            } else {
                alert("Session expired or invalid token.");
                window.location.href = "index.html";
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX error:", error);
            alert("Something went wrong. Try again.");
            window.location.href = "index.html";
        }
    });
});

function logout() {
    localStorage.removeItem("token");
    localStorage.removeItem("userId");
    window.location.href = "index.html";
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString(undefined, {
        year: "numeric",
        month: "long",
        day: "numeric"
    });
}
