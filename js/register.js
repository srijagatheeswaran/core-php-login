let usernameInput = document.getElementById("username");
let emailInput = document.getElementById("email");
let passwordInput = document.getElementById("password");
let confirmPasswordInput = document.getElementById("confirm-password");
let messageBox = document.getElementById("messageBox");
let registerForm = document.getElementById("registerForm");

function clearErrors() {
    document.getElementById("username-error").innerText = "";
    document.getElementById("email-error").innerText = "";
    document.getElementById("password-error").innerText = "";
    document.getElementById("repassword-error").innerText = "";
    messageBox.innerText = "";
}

function register(e) {
    e.preventDefault(); // Prevent default form submission
    clearErrors();

    let username = usernameInput.value.trim();
    let email = emailInput.value.trim();
    let password = passwordInput.value.trim();
    let confirmPassword = confirmPasswordInput.value.trim();

    let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    let hasError = false;

    if (!username) {
        document.getElementById("username-error").innerText = "Username is required.";
        hasError = true;
    }

    if (!email) {
        document.getElementById("email-error").innerText = "Email is required.";
        hasError = true;
    } else if (!emailPattern.test(email)) {
        document.getElementById("email-error").innerText = "Invalid email format.";
        hasError = true;
    }

    if (!password) {
        document.getElementById("password-error").innerText = "Password is required.";
        hasError = true;
    }

    if (password !== confirmPassword) {
        document.getElementById("repassword-error").innerText = "Passwords do not match.";
        hasError = true;
    }

    if (hasError) return;

    const formData = new FormData();
    formData.append('username', username);
    formData.append('email', email);
    formData.append('password', password);
    formData.append('confirmPassword', confirmPassword);

    fetch("php/register.php", {
        method: "POST",
        body: formData
    })
        .then(response => response.json())
        .then(data => {
            messageBox.textContent = data.message;
            messageBox.className = data.status === "success"
                ? "text-success text-center mt-3"
                : "text-danger text-center mt-3";

            if (data.status === "success") {
            
                if (data.token && data.user) {
                    localStorage.setItem("token", data.token);
                    localStorage.setItem("userId", data.user);
                }

                registerForm.reset();
                setTimeout(() => {
                    window.location.href = "profile.html";
                }, 1200);
            }
        })
        .catch(error => {
            messageBox.textContent = "An error occurred. Please try again.";
            messageBox.className = "text-danger text-center mt-3";
            console.error("Register error:", error);
        });
}
