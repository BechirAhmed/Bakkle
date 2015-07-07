function analyzeImage() {
    document.getElementById("TokenContainer").style.visibility = 'hidden';
    var imageUrl = document.getElementById("Image1Input").value;
    document.getElementById("Image1View").src=imageUrl;
    uploadImage(imageUrl);
};

function uploadImage(imageUrl)
{
    var myData = 'focus[x]=480&focus[y]=640&image_request[altitude]=27.912109375&image_request[language]=en&image_request[latitude]=35.8714220766008&image_request[locale]=en_US&image_request[longitude]=14.3583203002251&image_request[remote_image_url]='
        + imageUrl;

    $.ajax({
        url: 'https://camfind.p.mashape.com/image_requests/',
        type: 'POST',
        headers: {'X-Mashape-Key':'1Bho5rwG1rmshShIi5HlhOQcrn1qp1lCHyCjsnwqcD1gCLU1XI', 'Content-Type':'application/x-www-form-urlencoded', 'Accept':'application/json' },
        data: myData,
        dataType: 'json',
        success: function (result) {
            switch (result) {
                case true:
                    processResponse(result);
                    break;
                default:
                    document.getElementById("TokenLabel").textContent = result.token;
                    document.getElementById("TokenContainer").style.visibility = 'visible';
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
};

function getTags()
{
    var token = document.getElementById("TokenLabel").textContent;

    $.ajax({
        url: 'https://camfind.p.mashape.com/image_responses/' + token,
        type: 'GET',
        headers: {'X-Mashape-Key':'1Bho5rwG1rmshShIi5HlhOQcrn1qp1lCHyCjsnwqcD1gCLU1XI', 'Content-Type':'application/x-www-form-urlencoded', 'Accept':'application/json' },
        dataType: 'json',
        success: function (result) {
            switch (result) {
                case true:
                    processResponse(result);
                    break;
                default:
                    document.getElementById("TagsLabel").textContent = "Status:" + result.status + " Name:" + result.name;
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });

}

