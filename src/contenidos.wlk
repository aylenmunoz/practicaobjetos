// Empresa que comercializa los contenidos

object empresa {
	
	const usuariosRegistrados = #{}
	
	method calcularPrecioDescarga(unProducto, unUsuario){
		const derechosDeAutor = unProducto.valorDerechoAutor()
		const montoEmpresaDelUsuario = unUsuario.cobroEmpresaTelPorDescarga(unProducto)
		const montoEmpresaComercializacion = self.gananciaEmpresaPorDescarga(unProducto)
	
		const precioBruto = derechosDeAutor + montoEmpresaDelUsuario + montoEmpresaComercializacion	
	
		const recargoPrecio = unUsuario.precioRecargado(precioBruto)
		
		return precioBruto + recargoPrecio	
	}

	method gananciaEmpresaPorDescarga (unProducto){
		return unProducto.valorDerechoAutor() * 0.25
	}

	method registrarDescarga(unProducto, unUsuario){
		
		const precioDescarga = self.calcularPrecioDescarga(unProducto,unUsuario)
		
		if (!unUsuario.puedeRealizarLaDescarga(precioDescarga)){
			throw new Exception (message = "El usuario no puede realizar la descarga")
		}
		
		const contenido = new Descarga(producto = unProducto, fecha = new Date())
		
		unUsuario.descargar(contenido,precioDescarga)
	}
	
	method productoMasDescargado(anioDeInteres,mesDeInteres){
		const descargasDeUsuarios = usuariosRegistrados.map { usuario => usuario.descargas() }
		const descargasQueOcurrieronEnUnaFecha = descargasDeUsuarios.flatMap{ descarga => descarga.perteneceAMesYAnio(anioDeInteres,mesDeInteres)}																									
		const productos = descargasQueOcurrieronEnUnaFecha.map { descarga => descarga.producto() }
		return productos.max { producto => productos.occurrencesOf(producto) }
	}
}

// Descargas

class Descarga {
	const property producto
	const property fecha

	method perteneceAMesYAnio(anioEnElQueEstamos, mesEnElQueEstamos){
    return (anioEnElQueEstamos == fecha().year()) && (mesEnElQueEstamos == fecha().month())
	}
	
	method perteceALaFechaActual(fechaActual){
		return fechaActual == fecha()
	}
}




// Usuarios

class Usuario {
	
	var empresaDeTelecomunicaciones
	var tipoDeUsuario
	var saldoDisponible
	const descargas = []
	var importeFactura
	
	method cobroEmpresaTelPorDescarga(unProducto){
		return empresaDeTelecomunicaciones.cobroPorDescarga(unProducto)
	}
	
	method precioRecargado(precioBruto){
		return tipoDeUsuario.precioRecargo(precioBruto)
	}
	
	method puedeRealizarLaDescarga(precioDescarga){
		return tipoDeUsuario.puedeDescargar(precioDescarga,saldoDisponible)
	}
	
	method descargar(contenido,precioDescarga){
		descargas.add(contenido)
		tipoDeUsuario.pagar(precioDescarga,self)
		
	}
	
	method actualizarSaldo(precioDescarga){
		saldoDisponible = saldoDisponible - precioDescarga
	}
	
	method actualizarFactura(precioDescarga){
		importeFactura = importeFactura + precioDescarga
	}

	method gastosDeDescargasDelMes(){ 
    	return self.descargasDelMes().sum { descarga => empresa.calcularPrecioDescarga(descarga.producto(), self) }
	}

	method descargasDelMes(){ 
    	const hoy = new Date().year()
    	return descargas.filter { descarga => descarga.perteneceAMesYAnio(hoy.year(), hoy.month() }
	}
	
	method esColgado(){
		const descargasUnicas = descargas.withoutDuplicates()
		return descargas.size() >  descargasUnicas.size()
	}
}

// Tipos de usuarios

object prepago {
	method precioRecargo(precio){
		return precio * 0.1
	}	
	
	method puedeDescargar(precioDescarga,saldoDisponible){
		return saldoDisponible >= precioDescarga
	}
	
	method pagar(precioDescarga,unUsuario){
		unUsuario.actualizarSaldo(precioDescarga)
	}
}


object facturado {
	
	method precioRecargo(precio){
		return 0
	}
	
	method puedeDescargar(precioDescarga,saldoDisponible){
		return true 
	}
	
	method pagar(precioDescarga,unUsuario){
		unUsuario.actualizarFactura(precioDescarga)
	}
}

// Empresas de telecomunicaciones usuarios

class EmpresaNacional {
	
	method cobroPorDescarga(unProducto){
		return unProducto.derechoDeAutor() * 0.05
	}
	
}

class EmpresaExtranjera {
	
	const impuesto
	
	method cobroPorDescarga(unProducto){
		return unProducto.derechoDeAutor() *0.05 + impuesto
	}

}


// Contenidos
class Rington {
	
	var  precioPorMinutoAutor 
	var duracionRington
		
	method valorDerechoAutor(){
		return duracionRington * precioPorMinutoAutor 
	}
		
}


class Chiste {
	
	const montoChiste
	var cantCaracteres
	
	method valorDerechoAutor(){
		return montoChiste * cantCaracteres 
	}
	
	
}

class Juego {
	
	var  montoJuego
	
	method valorDerechoAutor(){
		return montoJuego		
	}

}