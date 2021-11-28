#lang racket

(provide stylesheet)

;
; dies ist ein workaround, weil traditionelle css dateien nicht funktioniert haben.
;

(define stylesheet #<<END

* {
  font-family: "calibri";
}

html, body {
   margin:0;
   padding:0;
}

html {
  position: relative;
  min-height: 100%;
}
body {
  /* Margin bottom by footer height */
  margin-bottom: 60px;
}


a, a:hover, a:focus, a:active {
  text-decoration: none;
  color: black;
}

a#info {
  font-size: 20px;
  padding: 1px 8px;
  width: 20px;
  border-radius: 15px;
  border: solid #ccc;
  border-width: 3px;
  background-color: #005CA9;
  color: white;
  font-weight: bold;
  font-style: italic;
  font-size 1.5em;
  font-family: "Didot Italic";
  
}

header {
  display: flex;
  flex-direction: row;
  flex-grow: 1 2 1;
  justify-content: space-between;
  align-items: center;
  overflow: hidden;

}


h1 {

 font-size: 200%;
 position: absolute;

  left: 50%;
  -ms-transform: translateX(-50%) translateY(0%);
  -webkit-transform: translate(-50%,0%);
  transform: translate(-50%,0%);
  
}
img {
  width: 400px;
  height: auto;
  margin: 10px;
}

form#search {
  width: 20%;
  height: 20%;
  margin-right: 20px;
}

input#search-field {

  background-color: #eeeeee;
  font-size: 150%;

  width: 100%;
  height: 100%;
  border-radius: 50px;

}


input#search-field:hover {
  background-color: #dddddd;
}
 
p {
  font-size: 120%;
}

div.panels {
  display: flex;
  flex-direction: column;
  margin: 10px 5%;
  margin-bottom: 0px;
  
}

div.kindpanel {
  padding: 1% 2%;
  margin: 1% 3%;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-evenly;
  background-color: #eeeeee;
  border-radius: 10px;
}

div.kindpanel form {
  margin-left: 10px;
margin-right: 10px;
}

section.formsection {
  display: flex;
  flex-direction: row;
  align-items: center;


}

section.formsection form{
  margin: 0px;
  padding: 0px;
  margin-left: 20px;
}

p#subtext {
  margin-top: 5px;
  margin-bottom: 5px;
  margin-left: 10px;
}

p#abholungsinfo {
  margin-left: 10px;
  margin-right: 10px;
}

footer {
  position: absolute;
  bottom: 0;
  width: 100%;
  /* Set the fixed height of the footer here */
  height: 60px;
  background-color: #005CA9;
}


footer p{

padding: 0px;

margin: 0px;

color: #ffffff;

}


table {
  margin-left: 20%;
  font-size: 200%;
  padding: 10px;
 background-color: #eeeeee;
}

td {
  padding: 5px;
  padding-left: 20px;
  padding-right: 20px;
  text-align: center; 
    vertical-align: middle;
}

div#info p{
  margin-left: 10px;
  margin-right: 10px;
  padding: 5px 10px;
  background-color: #dddddd;
}

p#fullname {
  margin: 3%;
  font-size: 150%;
  font-weight: bold;
}

p#fullnameinfo {
text-align: center;
  font-size: 250%;
 
}

div#info {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
}

section#infosection {
padding: 10px;
 background-color: #eeeeee;
}

div#results {
  display: flex;
  flex-flow: column;
  margin-top: 5%;
  margin-bottom: 100px;
  
}

div#result {
 margin-bottom: 4%;
}

a#result {
  font-size: 250%;
  font-size: 200%;
 position: absolute;

  left: 50%;
  -ms-transform: translateX(-50%) translateY(0%);
  -webkit-transform: translate(-50%,0%);
  transform: translate(-50%,0%);
  
}


a#result:hover {
  color: #888888;
}

input#search-field {

  margin-top: 20px;
  font-size: 150%;
}

a#editlink, button#submitbutton {
  font-size: 150%;
  background-color: #ccc;
  padding: 5px 10px;
  border-radius: 15px;
width: 30%;
display: table;
  margin: 0 auto;
}

a#editlink:hover {
  color: #888888;
}



input#info-input {
  margin-left: 20px;
  font-size: 130%;
  height: 30%;
}

div#infodiv {
  display: flex;
flex-flow: row;
margin-right: 10px;
background-color: #dddddd;

align-items: center;

padding: 5px 10px;
margin: 5px;

}

div#infodiv p{

}

form#info section#infosection {
  width: 30%;
}

form table {
  margin-left: 100px;
}

div#tempspacer {
  display: flex;
  justify-content: center;
}



@media screen and (max-width: 1200px) {

div#tempspacer {
  width: 100%;
  display: flex;
  justify-content: center;
  flex-flow: column;  
}

div#tempspacer table{
  margin-top: 100px;
  width: 60%;
  margin: auto;
}


div#tempspacer section#infosection {
  width: 500px;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 100px;
}

div#tempsection {
  flex-flow: column;
}

div#infodiv {

}

}


@media screen and (max-width: 1100px) {


h1 {

 font-size: 150%;
  
}
img {
  width: 200px;
}
input#search-field {

  margin-top: 20px;
  font-size: 150%;
}

footer p{
  font-size: 120%
}

footer {

height: 40px;

}

p#subtext, p#abholungsinfo {
  font-size: 140%;
}

p#fullname {
  font-size: 180%;
}



}

@media screen and (max-width: 880px) {
  p#subtext, p#abholungsinfo {
  font-size: 110%;
}

p#fullname {
  font-size: 130%;
}


div#info {
  flex-flow: column;
}

table {
  margin-top: 50px;
  margin-left: 0%;
}

div.kindpanel {
  margin-left: 0px;
  margin-right: 0px;

}

div.panels {
  margin-left: 0px;
  margin-right: 0px;
}


}

@media screen and (max-width: 550px) {


h1 {

 font-size: 120%;
  
}
img {
  width: 150px;
}
input#search-field {

  margin-top: 20px;
  font-size: 150%;
}

}

div#spacer{
width:100%;
text-align: center;
margin-top: 30px;

}


button#deletebutton {
  background-color: #FF4A3D;
  font-size: 130%;
}

div#newdiv {
  width: 100%;
  margin: 0px;
  padding-top: 0px;
  padding-bottom: 100px;
}

div#newdiv a#new{
  float: right;
  margin-right: 10%;
  font-size: 200%;
  background-color: #005CA9;
  border-radius: 1000px;
  color: white;
  padding: 10px 20px;
box-shadow: rgba(50, 50, 93, 0.25) 0px 13px 27px -5px, rgba(0, 0, 0, 0.3) 0px 8px 16px -8px;
}

div#newdiv a#new:hover{
  background-color: #00437A;
  color: #eeeeee;
}

div#datediv {
  display: flex;
  flex-flow: row;
  align-items: center;
}


.arrow {
  border: solid black;
  border-width: 0 3px 3px 0;
  display: inline-block;
  padding: 5px;
  margin: 5px;
  
}

.right {
  transform: rotate(-45deg);
  -webkit-transform: rotate(-45deg);
}

.left {
  transform: rotate(135deg);
  -webkit-transform: rotate(135deg);
}

.up {
  transform: rotate(-135deg);
  -webkit-transform: rotate(-135deg);
}

.down {
  transform: rotate(45deg);
  -webkit-transform: rotate(45deg);
}

/*button section*/

.switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;
}

/* Hide default HTML checkbox */
.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

/* The slider */
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  -webkit-transition: .4s;
  transition: .4s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  -webkit-transition: .4s;
  transition: .4s;
}

input:checked + .slider {
  background-color: #005CA9;
}

input:focus + .slider {
  box-shadow: 0 0 1px #005CA9;
}

input.krank_button:checked + .slider {
background-color: #FF4A3D;
}

input.krank_button:focus + .slider {
  box-shadow: 0 0 1px #FF4A3D;
}

input.abgeholt_button:checked + .slider {
background-color: #87D358;
}

input.abgeholt_button:focus + .slider {
  box-shadow: 0 0 1px #87D358;
}

input:checked + .slider:before {
  -webkit-transform: translateX(26px);
  -ms-transform: translateX(26px);
  transform: translateX(26px);
}

/* Rounded sliders */
.slider.round {
  border-radius: 34px;
}

.slider.round:before {
  border-radius: 50%;
}


END
    )