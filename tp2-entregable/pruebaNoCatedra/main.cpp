
#include <cstdlib>
#include <iostream>

using namespace std;

int main()
{

int i = 0;
while(i<30){

    int alto = rand();
    int ancho = rand();

   alto = (alto % 1024) +16;
    ancho = (ancho % 1024) +16;
    cout << alto << "x"<< ancho<< endl;
    i++;
}


    return 0;
}
