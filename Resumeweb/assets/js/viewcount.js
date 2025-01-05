const counter = document.querySelector(".count-number");
async function UpdateCounter() {
    let response = await fetch('https://6t4t3b7ow3bq5eaxam7vate5rm0hchcs.lambda-url.ap-southeast-1.on.aws/');
    let data = await response.json();
    counter.innerHTML = `Views: ${data}`;
}

UpdateCounter()

