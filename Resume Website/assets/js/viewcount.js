const counter = document.querySelector(".count-number");
async function UpdateCounter() {
    let response = await fetch('https://r6sj2vkt7adudneacxn3ipimje0johzf.lambda-url.ap-southeast-1.on.aws/');
    let data = await response.json();
    counter.innerHTML = `Views: ${data}`;
}

UpdateCounter()

