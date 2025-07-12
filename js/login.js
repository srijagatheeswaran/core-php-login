let emailId = document.getElementById("email");
let password = document.getElementById("password");
let messageBox = document.getElementById("messageBox");

let loginButton = document.getElementById("loginButton");

function login(e) {
  e.preventDefault();
  document.getElementById("email-error").innerText = "";
  document.getElementById("password-error").innerText = "";
  if (messageBox) messageBox.innerText = "";

  let email = emailId.value.trim();
  let pass = password.value.trim();
  let emailformat = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

  let hasError = false;

  if (email === "") {
    document.getElementById("email-error").innerText = "Email is required.";
    hasError = true;
  } else if (!emailformat.test(email)) {
    document.getElementById("email-error").innerText = "Invalid email format.";
    hasError = true;
  }
  if (pass === "") {
    document.getElementById("password-error").innerText = "Password is required.";
    hasError = true;
  }

  if (hasError) return;

  const formData = new FormData();
  formData.append('email', email);
  formData.append('password', pass);
  console.log("Form Data:", formData);
  loginButton.disabled = true;

  fetch("php/login.php", {
    method: "POST",
    body: formData,
  })
    .then((response) => response.json())
    .then((data) => {
      if (messageBox) {
        messageBox.textContent = data.message;
        messageBox.className = data.status === "success"
          ? "text-success text-center mt-3"
          : "text-danger text-center mt-3";
      }

      if (data.status === "success") {
        localStorage.setItem("userId", data.user);
        localStorage.setItem("token", data.token);
        setTimeout(() => {
          window.location.href = "profile.html";
        }, 1000);
      }
      loginButton.disabled = false;
    })
    .catch((error) => {
      if (messageBox) {
        messageBox.textContent = "An error occurred. Please try again.";
        messageBox.className = "text-danger text-center mt-3";
      }
      console.error("Login error:", error);
      loginButton.disabled = false;
    });
}
